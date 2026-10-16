import Foundation

struct TWScrapeClient {
    static let shared = TWScrapeClient()

    private enum Ops {
        static let listTimeline = "BkauSnPUDQTeeJsxq17opA/ListLatestTweetsTimeline"
        static let userTweets = "HeWHY26ItCfUmm1e6ITjeA/UserTweets"
        static let tweetDetail = "_8aYOgEDz35BrBcBal1-_w/TweetDetail"
    }

    private var listId: String { XAuthStore.shared.listId }
    private let gqlClient: TWScrapeGraphQLClient

    init(graphQLClient: TWScrapeGraphQLClient = TWScrapeGraphQLClient()) {
        self.gqlClient = graphQLClient
    }

    func fetchListTimeline() async throws -> [Tweet] {
        let page = try await gqlClient.singleRequest(
            op: Ops.listTimeline,
            variables: ["listId": listId, "count": 20],
            fieldToggles: ["withArticleRichContentState": false]
        )
        let tweets = newestFirst(TWScrapeParser.parseTweets(from: page, limit: -1))
        return tweets
    }

    func fetchListTimelinePage(cursor: String? = nil, pageSize: Int = 20) async throws -> (tweets: [Tweet], nextCursor: String?) {
        var variables: [String: Any] = ["listId": listId, "count": pageSize]
        if let cursor = cursor {
            variables["cursor"] = cursor
        }

        let page = try await gqlClient.singleRequest(
            op: Ops.listTimeline,
            variables: variables,
            fieldToggles: ["withArticleRichContentState": false]
        )

        let tweets = newestFirst(TWScrapeParser.parseTweets(from: page, limit: -1))
        let nextCursor = TWScrapeGraphQLClient.findCursor(in: page, type: TWScrapeGraphQLClient.CursorType.bottom.rawValue)

        return (tweets, nextCursor)
    }

    func fetchUserTweets(userId: Int, limit: Int = 20) async throws -> [Tweet] {
        let pageSize = max(1, min(limit, 20))
        let pages = try await gqlClient.pagedRequest(
            op: Ops.userTweets,
            baseVariables: [
                "userId": String(userId),
                "includePromotedContent": true,
                "withQuickPromoteEligibilityTweetFields": true,
                "withVoice": true,
                "withV2Timeline": true
            ],
            limit: limit,
            pageSize: pageSize,
            cursorType: .bottom
        )

        return mergeTweets(from: pages, limit: limit)
    }

    func fetchReplies(for tweetId: Int, limit: Int = 80) async throws -> [Tweet] {
        let pages = try await gqlClient.pagedRequest(
            op: Ops.tweetDetail,
            baseVariables: [
                "focalTweetId": String(tweetId),
                "referrer": "tweet",
                "with_rux_injections": true,
                "includePromotedContent": true,
                "withCommunity": true,
                "withQuickPromoteEligibilityTweetFields": true,
                "withBirdwatchNotes": true,
                "withVoice": true,
                "withV2Timeline": true
            ],
            limit: limit,
            pageSize: 40,
            cursorType: .showMoreThreads
        )

        let tweets = mergeTweets(from: pages, limit: limit)
        return tweets.filter { $0.inReplyToTweetId == tweetId }
    }

    func searchTweets(query: String, limit: Int = 40) async throws -> [Tweet] {
        let pages = try await TWScrapeSearchClient().search(query: query, product: "Latest", limit: limit)
        var ids = Set<Int>()
        return Array(pages.flatMap(\.tweets).filter { ids.insert($0.id).inserted }.prefix(max(0, limit)))
    }

    func searchUsers(query: String, limit: Int = 20) async throws -> [User] {
        let pages = try await TWScrapeSearchClient().search(query: query, product: "People", limit: limit)
        var ids = Set<Int>()
        return Array(pages.flatMap(\.users).filter { ids.insert($0.id).inserted }.prefix(max(0, limit)))
    }

    private func mergeTweets(from pages: [[String: Any]], limit: Int) -> [Tweet] {
        var all: [Tweet] = []
        var ids = Set<Int>()

        for page in pages {
            let parsed = TWScrapeParser.parseTweets(from: page, limit: -1)
            for tweet in parsed where !ids.contains(tweet.id) {
                ids.insert(tweet.id)
                all.append(tweet)
                if limit > 0 && all.count >= limit {
                    return all
                }
            }
        }
        return all
    }

    private func newestFirst(_ tweets: [Tweet]) -> [Tweet] {
        return tweets.sorted { $0.date > $1.date }
    }
}
