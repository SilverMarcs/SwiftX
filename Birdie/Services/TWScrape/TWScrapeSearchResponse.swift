import Foundation

/// Adapts X's current search fields to the shared tweet parser without changing other endpoints.
struct TWScrapeSearchResponse {
    let tweets: [Tweet]
    let users: [User]
    let nextCursor: String?

    init(json: [String: Any]) throws {
        if let errors = json["errors"] as? [Any], !errors.isEmpty {
            throw TWScrapeSearchError.apiError
        }
        guard let data = json["data"] as? [String: Any],
              let search = data["search_by_raw_query"] as? [String: Any],
              let searchTimeline = search["search_timeline"] as? [String: Any],
              let timeline = searchTimeline["timeline"] as? [String: Any],
              let instructions = timeline["instructions"] as? [[String: Any]] else {
            throw TWScrapeSearchError.invalidResponse
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

        let normalized = Self.normalize(json) as? [String: Any] ?? [:]
        let parsedTweets = Dictionary(TWScrapeParser.parseTweets(from: normalized).map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let parsedUsers = Dictionary(TWScrapeParser.parseUsers(from: normalized).map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var seenTweets = Set<Int>()
        var seenUsers = Set<Int>()
        tweets = tweetIDs.filter { seenTweets.insert($0).inserted }.compactMap { parsedTweets[$0] }
        users = userIDs.filter { seenUsers.insert($0).inserted }.compactMap { parsedUsers[$0] }
        nextCursor = cursor
        guard tweetIDs.isEmpty || !tweets.isEmpty, userIDs.isEmpty || !users.isEmpty else {
            throw TWScrapeSearchError.invalidResponse
        }
    }

    private static func result(in item: [String: Any], key: String) -> [String: Any]? {
        (item[key] as? [String: Any])?["result"] as? [String: Any]
    }

    private static func resultID(_ result: [String: Any]) -> Int? {
        let tweet = result["tweet"] as? [String: Any] ?? result
        return (tweet["rest_id"] as? String).flatMap(Int.init)
    }

    private static func normalize(_ value: Any) -> Any {
        if let array = value as? [Any] { return array.map { normalize($0) } }
        guard let dictionary = value as? [String: Any] else { return value }
        var object = dictionary.mapValues { normalize($0) }
        var legacy = object["legacy"] as? [String: Any] ?? [:]
        switch object["__typename"] as? String {
        case "User":
            let core = object["core"] as? [String: Any] ?? [:]
            legacy["name"] = core["name"] ?? legacy["name"]
            legacy["screen_name"] = core["screen_name"] ?? legacy["screen_name"]
            let bio = object["profile_bio"] as? [String: Any] ?? [:]
            legacy["description"] = bio["description"] ?? legacy["description"] ?? ""
            legacy["entities"] = bio["entities"] ?? legacy["entities"]
            legacy["created_at"] = core["created_at"] ?? legacy["created_at"] ?? ""
            legacy["profile_image_url_https"] = (object["avatar"] as? [String: Any])?["image_url"] ?? legacy["profile_image_url_https"]
            let counts = object["relationship_counts"] as? [String: Any] ?? [:]
            legacy["followers_count"] = counts["followers"] ?? legacy["followers_count"]
            legacy["friends_count"] = counts["following"] ?? legacy["friends_count"]
            legacy["statuses_count"] = (object["tweet_counts"] as? [String: Any])?["tweets"] ?? legacy["statuses_count"]
            legacy["is_blue_verified"] = (object["verification"] as? [String: Any])?["is_blue_verified"] ?? object["is_blue_verified"]
            object["legacy"] = legacy
        case "Tweet":
            let details = object["details"] as? [String: Any] ?? [:]
            legacy["full_text"] = details["full_text"] ?? legacy["full_text"]
            if let milliseconds = details["created_at_ms"] as? NSNumber {
                legacy["created_at"] = Date(timeIntervalSince1970: milliseconds.doubleValue / 1000).ISO8601Format()
            }
            for (key, count) in object["counts"] as? [String: Any] ?? [:] { legacy[key] = count }
            if let core = object["core"] as? [String: Any], let author = result(in: core, key: "user_results") {
                legacy["user_id_str"] = author["rest_id"]
            }
            if let media = object["media_entities2"] as? [[String: Any]] {
                legacy["extended_entities"] = ["media": media]
            }
            var entities = legacy["entities"] as? [String: Any] ?? [:]
            entities["hashtags"] = details["hashtag_entities"] ?? entities["hashtags"]
            entities["urls"] = object["url_entities"] ?? entities["urls"]
            entities["user_mentions"] = object["mention_entities"] ?? entities["user_mentions"]
            legacy["entities"] = entities
            if let reply = object["reply_to_results"] as? [String: Any] { legacy["in_reply_to_status_id_str"] = reply["rest_id"] }
            if let author = result(in: object, key: "reply_to_user_results") { legacy["in_reply_to_user_id_str"] = author["rest_id"] }
            if let quote = result(in: object, key: "quoted_tweet_results") {
                object["quoted_status_result"] = ["result": quote]
            }
            if let retweet = result(in: object, key: "retweeted_tweet_results") {
                object["retweeted_status_result"] = ["result": retweet]
            }
            if let note = object["note_tweet"] as? [String: Any], note["text"] != nil {
                object["note_tweet"] = ["note_tweet_results": ["result": note]]
            }
            object["legacy"] = legacy
        default:
            break
        }
        return object
    }
}
