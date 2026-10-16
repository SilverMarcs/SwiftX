import Foundation
import Observation

@MainActor
@Observable
final class TimelineStore {
    private(set) var entries: [TimelineEntry] = []
    private(set) var nextCursor: String?
    private(set) var isRefreshing = false
    private(set) var isLoadingMore = false
    private(set) var error: String?
    private(set) var loadMoreError: String?

    private let client: any TimelineLoading
    private let seen: SeenPostStore
    // Temporarily disabled; retain the tracking implementation for later.
    private let tracksSeenPosts: Bool
    private var accountKey: String?
    private var generation = UUID()
    private var requestTask: Task<TimelinePage, any Error>?
    private var usedCursors = Set<String>()
    private var emptyPages = 0

    init(client: any TimelineLoading = XClient.shared, seen: SeenPostStore = SeenPostStore(), tracksSeenPosts: Bool = false) {
        self.client = client
        self.seen = seen
        self.tracksSeenPosts = tracksSeenPosts
    }

    func configure(accountKey: String?) {
        guard self.accountKey != accountKey else { return }
        requestTask?.cancel()
        requestTask = nil
        generation = UUID()
        self.accountKey = accountKey
        entries = []
        nextCursor = nil
        usedCursors = []
        emptyPages = 0
        isRefreshing = false
        isLoadingMore = false
        error = nil
        loadMoreError = nil
        if tracksSeenPosts, let accountKey { seen.configure(accountKey: accountKey) }
    }

    func refresh() async {
        guard accountKey != nil else { return }
        generation = UUID()
        let generation = generation
        requestTask?.cancel()
        isRefreshing = true
        isLoadingMore = false
        loadMoreError = nil
        let sent = tracksSeenPosts ? seen.pending : []
        let refreshing = !entries.isEmpty
        let task = Task { try await client.home(cursor: nil, seenIDs: sent, refreshing: refreshing) }
        requestTask = task
        defer {
            if self.generation == generation { isRefreshing = false; requestTask = nil }
        }
        do {
            let page = try await result(of: task)
            try Task.checkCancellation()
            guard self.generation == generation else { return }
            var ids = Set<String>()
            entries = page.entries.filter { ids.insert($0.post.id).inserted }
            nextCursor = page.isTerminated ? nil : page.nextCursor
            usedCursors = []
            emptyPages = 0
            error = nil
            if tracksSeenPosts { seen.acknowledge(sent) }
        } catch {
            if self.generation == generation, !Task.isCancelled, !(error is CancellationError) {
                self.error = error.localizedDescription
            }
        }
    }

    func loadMore() async {
        guard requestTask == nil, let cursor = nextCursor, !usedCursors.contains(cursor), accountKey != nil else { return }
        let generation = generation
        isLoadingMore = true
        loadMoreError = nil
        let sent = tracksSeenPosts ? seen.pending : []
        let task = Task { try await client.home(cursor: cursor, seenIDs: sent, refreshing: false) }
        requestTask = task
        defer {
            if self.generation == generation { isLoadingMore = false; requestTask = nil }
        }
        do {
            let page = try await result(of: task)
            try Task.checkCancellation()
            guard self.generation == generation else { return }
            var ids = Set(entries.map(\.post.id))
            let additions = page.entries.filter { ids.insert($0.post.id).inserted }
            entries.append(contentsOf: additions)
            emptyPages = additions.isEmpty ? emptyPages + 1 : 0
            usedCursors.insert(cursor)
            // Empty filtered pages can still advance. Bound consecutive no-progress
            // pages, repeated cursors, and cycles instead of requesting forever.
            if page.isTerminated || emptyPages >= 3 || page.nextCursor.map({ usedCursors.contains($0) }) == true {
                nextCursor = nil
            } else { nextCursor = page.nextCursor }
            if tracksSeenPosts { seen.acknowledge(sent) }
        } catch {
            if self.generation == generation, !Task.isCancelled, !(error is CancellationError) {
                loadMoreError = error.localizedDescription
            }
        }
    }

    func markVisible(_ entry: TimelineEntry) {
        guard tracksSeenPosts else { return }
        seen.markVisible(entry.post.id)
        if let repost = entry.post.repostedPost { seen.markVisible(repost.id) }
    }

    private func result(of task: Task<TimelinePage, any Error>) async throws -> TimelinePage {
        try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }
}
