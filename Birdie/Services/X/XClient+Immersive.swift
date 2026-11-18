import Foundation

extension XClient {
    /// The endless video timeline X shows after a video is opened full screen.
    ///
    /// X seeds it with the opened post (`pinnedTweetId`) and the screen it came from; the
    /// opened post itself is not repeated in the results. Pages hold roughly a dozen videos.
    func fetchImmersiveVideos(pinnedTweetID: Int, pageName: String = "home", cursor: String? = nil) async throws -> XTimelinePage {
        let variables: [String: Any] = [
            "pinnedTweetId": String(pinnedTweetID),
            "pageName": pageName,
            "cursor": cursor ?? NSNull()
        ]
        return try XTimelineResponse(json: await perform("immersiveTimelineQuery", variables: variables)).page
    }
}
