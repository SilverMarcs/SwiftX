import Foundation

struct TWScrapeClient {
    static let shared = TWScrapeClient()

    private enum Ops {
        static let listTimeline = "BkauSnPUDQTeeJsxq17opA/ListLatestTweetsTimeline"
        static let userTweets = "HeWHY26ItCfUmm1e6ITjeA/UserTweets"
        static let tweetDetail = "_8aYOgEDz35BrBcBal1-_w/TweetDetail"
        static let searchTimeline = "AIdc203rPpK_k_2KWSdm7g/SearchTimeline"
    }

    private let listId = "1661518034639659009" // DEFAULT_LIST_ID from Python config
    private let gqlClient: TWScrapeGraphQLClient

    init(graphQLClient: TWScrapeGraphQLClient = TWScrapeGraphQLClient()) {
        self.gqlClient = graphQLClient
    }

    func fetchListTimeline(limit: Int = 120) async throws -> [Tweet] {
        let pages = try await gqlClient.pagedRequest(
            op: Ops.listTimeline,
            baseVariables: ["listId": listId],
            fieldToggles: ["withArticleRichContentState": false],
            limit: limit,
            pageSize: 50,
            cursorType: .bottom
        )

        return mergeTweets(from: pages, limit: limit)
    }

    func fetchUserTweets(userId: Int, limit: Int = 60) async throws -> [Tweet] {
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
            pageSize: 40,
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
        guard !query.isEmpty else { return [] }

        let pages = try await gqlClient.pagedRequest(
            op: Ops.searchTimeline,
            baseVariables: [
                "rawQuery": query,
                "count": 20,
                "product": "Latest",
                "querySource": "typed_query"
            ],
            fieldToggles: ["withArticleRichContentState": false],
            limit: limit,
            pageSize: 20,
            cursorType: .bottom
        )

        return mergeTweets(from: pages, limit: limit)
    }

    func searchUsers(query: String, limit: Int = 20) async throws -> [User] {
        guard !query.isEmpty else { return [] }

        let pages = try await gqlClient.pagedRequest(
            op: Ops.searchTimeline,
            baseVariables: [
                "rawQuery": query,
                "count": 20,
                "product": "People",
                "querySource": "typed_query"
            ],
            fieldToggles: ["withArticleRichContentState": false],
            limit: limit,
            pageSize: 20,
            cursorType: .bottom
        )

        return mergeUsers(from: pages, limit: limit)
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

    private func mergeUsers(from pages: [[String: Any]], limit: Int) -> [User] {
        var all: [User] = []
        var ids = Set<Int>()

        for page in pages {
            let parsed = TWScrapeParser.parseUsers(from: page, limit: -1)
            for user in parsed where !ids.contains(user.id) {
                ids.insert(user.id)
                all.append(user)
                if limit > 0 && all.count >= limit {
                    return all
                }
            }
        }
        return all
    }
}
