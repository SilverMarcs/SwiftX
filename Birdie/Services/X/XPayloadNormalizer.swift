import Foundation

/// Maps current X web payloads into the common leaf parser while preserving nested posts.
enum XPayloadNormalizer {
    private static func result(in item: [String: Any], key: String) -> [String: Any]? {
        (item[key] as? [String: Any])?["result"] as? [String: Any]
    }

    static func normalize(_ value: Any) -> Any {
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
            if let milliseconds = core["created_at_ms"] as? NSNumber {
                legacy["created_at"] = Date(timeIntervalSince1970: milliseconds.doubleValue / 1000).ISO8601Format()
            }
            legacy["profile_image_url_https"] = (object["avatar"] as? [String: Any])?["image_url"] ?? legacy["profile_image_url_https"]
            legacy["profile_banner_url"] = (object["banner"] as? [String: Any])?["image_url"] ?? legacy["profile_banner_url"]
            legacy["location"] = (object["location"] as? [String: Any])?["location"] ?? legacy["location"]
            legacy["pinned_tweet_ids_str"] = (object["pinned_items"] as? [String: Any])?["tweet_ids_str"] ?? legacy["pinned_tweet_ids_str"]
            let counts = object["relationship_counts"] as? [String: Any] ?? [:]
            legacy["followers_count"] = counts["followers"] ?? legacy["followers_count"]
            legacy["friends_count"] = counts["following"] ?? legacy["friends_count"]
            legacy["statuses_count"] = (object["tweet_counts"] as? [String: Any])?["tweets"] ?? legacy["statuses_count"]
            legacy["is_blue_verified"] = (object["verification"] as? [String: Any])?["is_blue_verified"] ?? object["is_blue_verified"]
            legacy["verified"] = (object["verification"] as? [String: Any])?["verified"] ?? legacy["verified"]
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
            } else if let retweet = result(in: legacy, key: "retweeted_status_results") {
                // Current Relay timelines keep the repost's original post under legacy,
                // using a plural key even though this contains a single result.
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
