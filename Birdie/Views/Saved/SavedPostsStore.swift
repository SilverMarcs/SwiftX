import Foundation
import Observation

/// Loads the account's saved posts a page at a time, keeping both X's order and a shuffled one.
///
/// Shuffling never loads extra pages: each page is shuffled on its own as it arrives
/// and appended to the shuffled list, so scrolling down keeps paging as usual.
@MainActor
@Observable
final class SavedPostsStore {
    /// Posts in X's order, newest saved first.
    private(set) var tweets: [Tweet] = []
    /// The same posts, each page shuffled within itself.
    private(set) var shuffledTweets: [Tweet] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?
    private(set) var paginationErrorMessage: String?
    var nextCursor: String? { pagination.nextCursor }

    private var pagination = XTimelinePagination()
    @ObservationIgnored private var sessionRevision: UUID?

    func visibleTweets(in order: SavedPostsOrder) -> [Tweet] {
        guard sessionRevision == XSessionStore.shared.revision else { return [] }
        return order == .shuffled ? shuffledTweets : tweets
    }

    /// Reshuffles the posts loaded so far; later pages keep arriving shuffled.
    func shuffle() {
        shuffledTweets = tweets.shuffled()
    }

    /// Reloads from the first page. Saving or unsaving elsewhere doesn't change the
    /// list until this runs again, on pull to refresh or a new session.
    func load() async {
        let session = XSessionStore.shared
        let requestGeneration = pagination.beginRefresh()
        let expectedRevision = session.revision
        let expectedChange = XBookmarkStore.shared.changeRevision
        if sessionRevision != expectedRevision || !session.isAuthenticated {
            tweets = []
            shuffledTweets = []
            hasLoaded = false
        }
        sessionRevision = expectedRevision
        errorMessage = nil
        paginationErrorMessage = nil
        isLoadingMore = false
        guard session.isAuthenticated else { isLoading = false; return }
        isLoading = true
        defer { if pagination.generation == requestGeneration { isLoading = false } }
        do {
            let page = try await XClient.shared.fetchBookmarks()
            try Task.checkCancellation()
            guard pagination.isCurrent(requestGeneration, sessionRevision: expectedRevision) else { return }
            tweets = XTimelinePagination.uniqueItems(page.tweets)
            shuffledTweets = tweets.shuffled()
            XBookmarkStore.shared.recordSaved(tweets, sessionRevision: expectedRevision, ifUnchangedSince: expectedChange)
            pagination.finishFirstPage(nextCursor: page.nextCursor)
            hasLoaded = true
        } catch {
            guard pagination.isCurrent(requestGeneration, sessionRevision: expectedRevision),
                  !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }

    func loadNextPage() async {
        guard !isLoading, !isLoadingMore, let cursor = nextCursor,
              sessionRevision == XSessionStore.shared.revision else { return }
        let requestGeneration = pagination.generation
        let expectedRevision = XSessionStore.shared.revision
        let expectedChange = XBookmarkStore.shared.changeRevision
        isLoadingMore = true
        paginationErrorMessage = nil
        defer { if pagination.generation == requestGeneration { isLoadingMore = false } }
        do {
            let page = try await XClient.shared.fetchBookmarks(cursor: cursor)
            try Task.checkCancellation()
            guard pagination.isCurrent(requestGeneration, sessionRevision: expectedRevision) else { return }
            let fresh = XTimelinePagination.uniqueItems(page.tweets, excluding: tweets)
            tweets.append(contentsOf: fresh)
            shuffledTweets.append(contentsOf: fresh.shuffled())
            XBookmarkStore.shared.recordSaved(page.tweets, sessionRevision: expectedRevision, ifUnchangedSince: expectedChange)
            pagination.advance(after: cursor, nextCursor: page.nextCursor)
        } catch {
            guard pagination.isCurrent(requestGeneration, sessionRevision: expectedRevision),
                  !(error is CancellationError) else { return }
            paginationErrorMessage = error.localizedDescription
        }
    }
}
