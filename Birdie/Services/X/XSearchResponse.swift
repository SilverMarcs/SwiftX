import Foundation

/// Selects search results in server order and maps their current X payloads to app models.
struct XSearchResponse {
    let tweets: [Tweet]
    let users: [User]
    let nextCursor: String?

    init(json: [String: Any]) throws {
        if let errors = json["errors"] as? [Any], !errors.isEmpty {
            throw XClientError.apiError
        }
        guard let data = json["data"] as? [String: Any],
              let search = data["search_by_raw_query"] as? [String: Any],
              let searchTimeline = search["search_timeline"] as? [String: Any],
              let timeline = searchTimeline["timeline"] as? [String: Any],
              let instructions = timeline["instructions"] as? [[String: Any]] else {
            throw XClientError.invalidResponse
        }

        let entries = instructions.flatMap { $0["entries"] as? [[String: Any]] ?? [] }
        var tweetIDs: [Int] = []
        var userIDs: [Int] = []
        var cursor: String?
        for entry in entries {
            guard let content = entry["content"] as? [String: Any] else { continue }
            if content["cursor_type"] as? String == "Bottom" {
                cursor = content["value"] as? String
            }
            let items: [[String: Any]]
            if let moduleItems = content["items"] as? [[String: Any]] {
                items = moduleItems.compactMap { $0["item"] as? [String: Any] }
            } else {
                items = [content]
            }
            for item in items {
                guard let itemContent = item["content"] as? [String: Any] else { continue }
                if let result = Self.result(in: itemContent, key: "tweet_results"),
                   let id = Self.resultID(result) {
                    tweetIDs.append(id)
                }
                if let result = Self.result(in: itemContent, key: "user_results"),
                   let id = Self.resultID(result) {
                    userIDs.append(id)
                }
            }
        }

        let normalized = XPayloadNormalizer.normalize(json) as? [String: Any] ?? [:]
        let parsedTweets = Dictionary(XPostParser.parseTweets(from: normalized).map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let parsedUsers = Dictionary(XPostParser.parseUsers(from: normalized).map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var seenTweets = Set<Int>()
        var seenUsers = Set<Int>()
        tweets = tweetIDs.filter { seenTweets.insert($0).inserted }.compactMap { parsedTweets[$0] }
        users = userIDs.filter { seenUsers.insert($0).inserted }.compactMap { parsedUsers[$0] }
        nextCursor = cursor
        guard tweetIDs.isEmpty || !tweets.isEmpty, userIDs.isEmpty || !users.isEmpty else {
            throw XClientError.invalidResponse
        }
    }

    private static func result(in item: [String: Any], key: String) -> [String: Any]? {
        (item[key] as? [String: Any])?["result"] as? [String: Any]
    }

    private static func resultID(_ result: [String: Any]) -> Int? {
        let tweet = result["tweet"] as? [String: Any] ?? result
        return (tweet["rest_id"] as? String).flatMap(Int.init)
    }
}
