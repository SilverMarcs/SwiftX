import Foundation

struct XTimelinePage {
    let tweets: [Tweet]
    let nextCursor: String?

    init(tweets: [Tweet], nextCursor: String?) {
        self.tweets = tweets
        self.nextCursor = nextCursor
    }
}
