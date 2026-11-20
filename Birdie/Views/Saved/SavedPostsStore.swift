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

    func visibleTweets(in order: SavedPostsOrder) -> [Tweet] {
        order == .shuffled ? shuffledTweets : tweets
    }

    /// Reshuffles the posts loaded so far; later pages keep arriving shuffled.
    func shuffle() {
        shuffledTweets = tweets.shuffled()
    }

    /// Loads once, and clears when signed out. Switching accounts keeps what's shown
    /// until pull to refresh.
    func loadIfNeeded() async {
        if !XSessionStore.shared.isAuthenticated {
            clear()
        } else if !hasLoaded, !isLoading {
            await load()
        }
    }

    /// Reloads from the first page. Saving or unsaving elsewhere doesn't change the
    /// list until this runs again, on pull to refresh.
    func load() async {
        let session = XSessionStore.shared
        let requestGeneration = pagination.beginRefresh()
        let accountID = session.activeAccountID
        let expectedChange = XBookmarkStore.shared.changeRevision
        errorMessage = nil
        paginationErrorMessage = nil
        isLoadingMore = false
        guard session.isAuthenticated else { clear(); return }
        isLoading = true
        defer { if pagination.generation == requestGeneration { isLoading = false } }
        do {
            let page = try await XClient.shared.fetchBookmarks()
            guard pagination.isCurrent(requestGeneration) else { return }
            tweets = XTimelinePagination.uniqueItems(page.tweets)
            shuffledTweets = tweets.shuffled()
            XBookmarkStore.shared.recordSaved(tweets, accountID: accountID, ifUnchangedSince: expectedChange)
            pagination.finishFirstPage(nextCursor: page.nextCursor)
            hasLoaded = true
        } catch {
            guard pagination.isCurrent(requestGeneration), !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }

    func loadNextPage() async {
        guard !isLoading, !isLoadingMore, let cursor = nextCursor else { return }
        let requestGeneration = pagination.generation
        let accountID = XSessionStore.shared.activeAccountID
        let expectedChange = XBookmarkStore.shared.changeRevision
        isLoadingMore = true
        paginationErrorMessage = nil
        defer { if pagination.generation == requestGeneration { isLoadingMore = false } }
        do {
            let page = try await XClient.shared.fetchBookmarks(cursor: cursor)
            guard pagination.isCurrent(requestGeneration) else { return }
            let fresh = XTimelinePagination.uniqueItems(page.tweets, excluding: tweets)
            tweets.append(contentsOf: fresh)
            shuffledTweets.append(contentsOf: fresh.shuffled())
            XBookmarkStore.shared.recordSaved(page.tweets, accountID: accountID, ifUnchangedSince: expectedChange)
            pagination.advance(after: cursor, nextCursor: page.nextCursor)
        } catch {
            guard pagination.isCurrent(requestGeneration), !(error is CancellationError) else { return }
            paginationErrorMessage = error.localizedDescription
        }
    }

    private func clear() {
        _ = pagination.beginRefresh()
        tweets = []
        shuffledTweets = []
        isLoading = false
        isLoadingMore = false
        hasLoaded = false
        errorMessage = nil
        paginationErrorMessage = nil
    }
}
