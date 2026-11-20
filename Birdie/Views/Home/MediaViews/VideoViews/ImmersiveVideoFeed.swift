import Foundation
import SwiftMediaViewer

/// Feeds the full-screen video viewer from X's immersive timeline, one page at a time.
/// Item IDs are post IDs, which the page overlay uses for its Save button.
///
/// The viewer creates a fresh feed each time it opens, so cursors never leak between
/// presentations and nothing is fetched until the viewer asks for more.
@MainActor
final class ImmersiveVideoFeed: SMVVideoFeed {
    private let pinnedTweetID: Int
    private var cursor: String?
    private var consumedCursors = Set<String>()
    private var hasEnded = false

    /// - Parameter pinnedTweetID: The opened post, whose video is page 0.
    init(pinnedTweetID: Int) {
        self.pinnedTweetID = pinnedTweetID
    }

    func nextVideos() async throws -> [SMVVideoItem] {
        // Pages can hold only non-video posts, so keep going a little.
        for _ in 0..<3 {
            guard !hasEnded else { return [] }
            let page = try await XClient.shared.fetchImmersiveVideos(pinnedTweetID: pinnedTweetID, cursor: cursor)
            if let current = cursor { consumedCursors.insert(current) }
            if let next = page.nextCursor, !next.isEmpty, !consumedCursors.contains(next) {
                cursor = next
            } else {
                hasEnded = true
            }
            let items = page.tweets.compactMap(item(for:))
            if !items.isEmpty { return items }
        }
        return []
    }

    private func item(for tweet: Tweet) -> SMVVideoItem? {
        let post: any TweetContentProtocol
        if let retweeted = tweet.retweetedTweet { post = retweeted } else { post = tweet }
        guard let video = post.media?.videos?.first,
              let url = video.playbackURL else { return nil }
        XBookmarkStore.shared.recordKnownState(of: post)
        return SMVVideoItem(id: String(post.id), url: url,
                            thumbnailURL: URL(string: video.thumbnailUrl),
                            title: "Video by \(post.user.displayname)")
    }
}
