import Foundation

extension XClient {
    /// One page of the signed-in account's saved posts, newest saved first.
    func fetchBookmarks(cursor: String? = nil) async throws -> XTimelinePage {
        // X serves about 20 posts per page regardless of a larger count.
        let variables: [String: Any] = ["count": 20, "cursor": cursor ?? NSNull()]
        return try XTimelineResponse(json: await perform("BookmarkTimeline", variables: variables)).page
    }

    func setBookmarked(tweetID: Int, bookmarked: Bool) async throws {
        let json = try await perform(bookmarked ? "BookmarkAdd" : "BookmarkDelete",
                                     variables: ["tweetId": String(tweetID)])
        let field = bookmarked ? "tweet_bookmark_put" : "tweet_bookmark_delete"
        guard let data = json["data"] as? [String: Any], data[field] as? String == "Done" else {
            throw XClientError.apiError
        }
    }
}
