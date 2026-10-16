import Foundation
@testable import BirdieCore

nonisolated enum Fixtures {
    static func json(_ object: Any) throws -> JSONValue {
        try JSONDecoder().decode(JSONValue.self, from: JSONSerialization.data(withJSONObject: object))
    }

    static func user(_ id: String = "user") -> [String: Any] {
        ["__typename": "User", "rest_id": id, "core": ["name": "Example", "screen_name": "example"], "avatar": ["image_url": "https://example.com/avatar.jpg"], "relationship_perspectives": ["following": false]]
    }

    static func post(_ id: String, text: String = "Post", quote: [String: Any]? = nil) -> [String: Any] {
        var value: [String: Any] = ["__typename": "Tweet", "rest_id": id, "core": ["user_results": ["result": user()]], "details": ["full_text": text, "created_at_ms": 1_700_000_000_000], "counts": ["favorite_count": 9, "reply_count": 2, "retweet_count": 3, "bookmark_count": 4]]
        if let quote { value["quoted_tweet_results"] = ["result": quote] }
        return value
    }

    static func entry(_ id: String, post: [String: Any]) -> [String: Any] {
        ["entry_id": id, "content": ["__typename": "TimelineTimelineItem", "content": ["__typename": "TimelineTweet", "tweet_results": ["result": post]]]]
    }

    static func cursor(_ value: String) -> [String: Any] {
        ["entry_id": "cursor-bottom", "content": ["__typename": "TimelineTimelineCursor", "cursor_type": "Bottom", "value": value]]
    }

    static func timeline(_ entries: [[String: Any]], extra: [[String: Any]] = []) throws -> JSONValue {
        try json(["instructions": [["__typename": "TimelineAddEntries", "entries": entries]] + extra])
    }

    static func page(_ ids: [String], cursor: String? = nil) -> TimelinePage {
        TimelinePage(entries: ids.map { id in
            TimelineEntry(id: "entry-\(id)", post: Post(id: id, user: User(id: "user", username: "example", name: "Example")))
        }, nextCursor: cursor)
    }
}
