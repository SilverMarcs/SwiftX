import Foundation
import Observation

@MainActor
@Observable
final class FeedStore {
    private(set) var tweets: [Tweet] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private(set) var paginationErrorMessage: String?
    private(set) var nextCursor: String?

    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var filter: FeedFilter?
    @ObservationIgnored private var sessionRevision: UUID?
    @ObservationIgnored private var consumedCursors: Set<String> = []

    func loadIfNeeded(filter: FeedFilter, sessionRevision: UUID, isAuthenticated: Bool) async {
        guard tweets.isEmpty || self.filter != filter || self.sessionRevision != sessionRevision else { return }
        await load(filter: filter, sessionRevision: sessionRevision, isAuthenticated: isAuthenticated)
    }

    func load(filter: FeedFilter, sessionRevision: UUID, isAuthenticated: Bool) async {
        generation = UUID()
        let requestGeneration = generation
        let changedContext = self.filter != filter || self.sessionRevision != sessionRevision
        self.filter = filter
        self.sessionRevision = sessionRevision
        isLoadingMore = false
        errorMessage = nil
        paginationErrorMessage = nil
        // Recreate the pagination footer even if a refresh returns the same cursor.
        nextCursor = nil
        if changedContext || !isAuthenticated {
            tweets = []
            consumedCursors = []
            hasLoaded = false
        }
        guard isAuthenticated else {
            isLoading = false
            return
        }

        isLoading = true
        defer { if generation == requestGeneration { isLoading = false } }
        do {
            let page = try await XClient.shared.fetchFeed(filter: filter, cursor: nil)
            try Task.checkCancellation()
            guard generation == requestGeneration else { return }
            tweets = unique(page.tweets)
            nextCursor = page.nextCursor
            consumedCursors = []
            hasLoaded = true
        } catch {
            guard generation == requestGeneration, !Task.isCancelled, !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }

    func loadNextPage() async {
        guard !isLoading, !isLoadingMore, let filter, let cursor = nextCursor else { return }
        let requestGeneration = generation
        isLoadingMore = true
        paginationErrorMessage = nil
        defer { if generation == requestGeneration { isLoadingMore = false } }
        do {
            let page = try await XClient.shared.fetchFeed(filter: filter, cursor: cursor)
            try Task.checkCancellation()
            guard generation == requestGeneration else { return }
            var seen = Set(tweets.map(\.id))
            tweets.append(contentsOf: page.tweets.filter { seen.insert($0.id).inserted })
            consumedCursors.insert(cursor)
            // A repeated cursor can otherwise make an empty or duplicate page loop forever.
            nextCursor = page.nextCursor.flatMap { consumedCursors.contains($0) ? nil : $0 }
        } catch {
            guard generation == requestGeneration, !Task.isCancelled, !(error is CancellationError) else { return }
            paginationErrorMessage = error.localizedDescription
        }
    }

    private func unique(_ tweets: [Tweet]) -> [Tweet] {
        var seen: Set<Int> = []
        return tweets.filter { seen.insert($0.id).inserted }
    }
}
