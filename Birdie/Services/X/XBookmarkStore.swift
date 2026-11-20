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
    /// The account `states` and `pendingIDs` describe.
    private var accountID: Int?
    @ObservationIgnored private var primedAccountIDs = Set<Int>()

    private var activeAccountID: Int? { XSessionStore.shared.activeAccountID }

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
              !isPending(tweet.id) else { return }
        resetIfNeeded()
        states[tweet.id] = known
    }

    func state(for id: Int) -> Bool? {
        guard accountID == activeAccountID else { return nil }
        return states[id]
    }

    func isPending(_ id: Int) -> Bool {
        accountID == activeAccountID && pendingIDs.contains(id)
    }

    func toggle(_ tweet: any TweetContentProtocol) async throws {
        try await toggle(id: tweet.id, fallback: tweet.isBookmarked)
    }

    func toggle(id: Int, fallback: Bool? = nil) async throws {
        guard XSessionStore.shared.isAuthenticated else { throw XClientError.signedOut }
        resetIfNeeded()
        guard !pendingIDs.contains(id) else { return }
        let expectedAccountID = accountID
        let previous = isBookmarked(id: id, fallback: fallback)
        let saved = !previous
        states[id] = saved
        changeRevision = UUID()
        pendingIDs.insert(id)
        defer {
            if accountID == expectedAccountID { pendingIDs.remove(id) }
        }

        do {
            try await XClient.shared.setBookmarked(tweetID: id, bookmarked: saved)
        } catch {
            guard accountID == expectedAccountID else { throw error }
            states[id] = previous
            changeRevision = UUID()
            throw error
        }
    }

    /// The Saved endpoint establishes membership even when a row omits perspective.
    func recordSaved(_ tweets: [Tweet], accountID requestAccountID: Int?, ifUnchangedSince expectedChange: UUID) {
        guard requestAccountID == activeAccountID, changeRevision == expectedChange else { return }
        resetIfNeeded()
        for tweet in tweets where !pendingIDs.contains(tweet.id) {
            states[tweet.id] = true
        }
    }

    /// Most timelines omit a post's saved state, so learn each account's most recently saved posts once.
    func primeIfNeeded() async {
        guard XSessionStore.shared.isAuthenticated, let requestAccountID = activeAccountID,
              primedAccountIDs.insert(requestAccountID).inserted else { return }
        let expectedChange = changeRevision
        var cursor: String?
        for _ in 0..<5 where activeAccountID == requestAccountID {
            guard let page = try? await XClient.shared.fetchBookmarks(cursor: cursor) else { return }
            recordSaved(page.tweets, accountID: requestAccountID, ifUnchangedSince: expectedChange)
            guard let next = page.nextCursor, !next.isEmpty, next != cursor, !page.tweets.isEmpty else { return }
            cursor = next
        }
    }

    private func resetIfNeeded() {
        guard accountID != activeAccountID else { return }
        accountID = activeAccountID
        states = [:]
        pendingIDs = []
    }
}
