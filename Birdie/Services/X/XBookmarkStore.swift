import Foundation
import Observation

/// Account-scoped overrides keep a post's bookmark button in sync across every list.
@MainActor
@Observable
final class XBookmarkStore {
    static let shared = XBookmarkStore()

    private(set) var states: [Int: Bool] = [:]
    private(set) var pendingIDs: Set<Int> = []
    private(set) var changeRevision = UUID()
    private var sessionRevision: UUID?
    @ObservationIgnored private var primedRevision: UUID?

    func isBookmarked(_ tweet: any TweetContentProtocol) -> Bool {
        isBookmarked(id: tweet.id, fallback: tweet.isBookmarked)
    }

    /// For callers that only have a post ID, such as the video viewer's overlay.
    func isBookmarked(id: Int, fallback: Bool? = nil) -> Bool {
        state(for: id) ?? fallback ?? false
    }

    /// Keeps a saved state a payload reported, for later lookups by ID alone.
    func recordKnownState(of tweet: any TweetContentProtocol) {
        guard let known = tweet.isBookmarked, state(for: tweet.id) == nil,
              !pendingIDs.contains(tweet.id) else { return }
        resetIfNeeded(XSessionStore.shared.revision)
        states[tweet.id] = known
    }

    func state(for id: Int) -> Bool? {
        guard sessionRevision == XSessionStore.shared.revision else { return nil }
        return states[id]
    }

    func isPending(_ id: Int) -> Bool {
        sessionRevision == XSessionStore.shared.revision && pendingIDs.contains(id)
    }

    func toggle(_ tweet: any TweetContentProtocol) async throws {
        try await toggle(id: tweet.id, fallback: tweet.isBookmarked)
    }

    func toggle(id: Int, fallback: Bool? = nil) async throws {
        let session = XSessionStore.shared
        guard session.isAuthenticated else { throw XClientError.signedOut }
        resetIfNeeded(session.revision)
        guard !pendingIDs.contains(id) else { return }
        let expectedRevision = session.revision
        let previous = isBookmarked(id: id, fallback: fallback)
        let saved = !previous
        states[id] = saved
        changeRevision = UUID()
        pendingIDs.insert(id)
        defer {
            if sessionRevision == expectedRevision { pendingIDs.remove(id) }
        }

        do {
            try await XClient.shared.setBookmarked(tweetID: id, bookmarked: saved)
            try Task.checkCancellation()
            guard expectedRevision == session.revision else { throw CancellationError() }
        } catch {
            guard expectedRevision == session.revision else { throw CancellationError() }
            states[id] = previous
            changeRevision = UUID()
            throw error
        }
    }

    /// The Saved endpoint establishes membership even when a row omits perspective.
    func recordSaved(_ tweets: [Tweet], sessionRevision: UUID, ifUnchangedSince expectedChange: UUID) {
        guard sessionRevision == XSessionStore.shared.revision, changeRevision == expectedChange else { return }
        resetIfNeeded(sessionRevision)
        for tweet in tweets where !pendingIDs.contains(tweet.id) {
            states[tweet.id] = true
        }
    }

    /// Most timelines omit a post's saved state, so learn the most recently saved posts once per session.
    func primeIfNeeded() async {
        let session = XSessionStore.shared
        guard session.isAuthenticated, primedRevision != session.revision else { return }
        let expectedRevision = session.revision
        primedRevision = expectedRevision
        let expectedChange = changeRevision
        var cursor: String?
        for _ in 0..<5 {
            guard let page = try? await XClient.shared.fetchBookmarks(cursor: cursor) else { return }
            recordSaved(page.tweets, sessionRevision: expectedRevision, ifUnchangedSince: expectedChange)
            guard let next = page.nextCursor, !next.isEmpty, next != cursor, !page.tweets.isEmpty else { return }
            cursor = next
        }
    }

    private func resetIfNeeded(_ expectedRevision: UUID) {
        guard sessionRevision != expectedRevision else { return }
        sessionRevision = expectedRevision
        states = [:]
        pendingIDs = []
    }
}
