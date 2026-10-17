import Foundation

/// Selects only explicit timeline rows before decoding their payloads. Nested quotes and
/// reposts stay attached to their row, and never become extra rows by recursive discovery.
struct XTimelineResponse {
    let page: XTimelinePage

    var tweets: [Tweet] { page.tweets }
    var nextCursor: String? { page.nextCursor }

    init(json: [String: Any]) throws {
        if let errors = json["errors"] as? [Any], !errors.isEmpty {
            throw XClientError.apiError
        }
        guard let instructions = Self.instructions(in: json) else {
            throw XClientError.invalidResponse
        }

        var selected: [[String: Any]] = []
        var ids: [Int] = []
        var nextCursor: String?
        for instruction in instructions {
            var entries = instruction["entries"] as? [[String: Any]] ?? []
            if let entry = instruction["entry"] as? [String: Any] { entries.append(entry) }
            // Pagination can append more items to an existing conversation module.
            if let items = instruction["moduleItems"] as? [[String: Any]]
                ?? instruction["module_items"] as? [[String: Any]] {
                entries.append(["content": ["items": items]])
            }
            for entry in entries {
                guard !Self.isPromoted(entry), let content = entry["content"] as? [String: Any],
                      !Self.isPromoted(content) else { continue }
                if (content["cursorType"] ?? content["cursor_type"]) as? String == "Bottom" {
                    nextCursor = content["value"] as? String
                    continue
                }
                let items = content["items"] as? [[String: Any]] ?? [content]
                for item in items {
                    guard !Self.isPromoted(item) else { continue }
                    let container = item["item"] as? [String: Any] ?? item
                    guard !Self.isPromoted(container) else { continue }
                    let itemContent = container["itemContent"] as? [String: Any]
                        ?? container["content"] as? [String: Any]
                        ?? container
                    guard !Self.isPromoted(itemContent),
                          let results = itemContent["tweet_results"] as? [String: Any],
                          let result = results["result"] as? [String: Any],
                          !Self.isPromoted(result) else { continue }
                    let tweet = result["tweet"] as? [String: Any] ?? result
                    guard let id = (tweet["rest_id"] as? String).flatMap(Int.init) else { continue }
                    ids.append(id)
                    selected.append(result)
                }
            }
        }

        let normalized = XPayloadNormalizer.normalize(["selected": selected]) as? [String: Any] ?? [:]
        let parsed = Dictionary(
            XPostParser.parseTweets(from: normalized).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        var seen = Set<Int>()
        let tweets = ids.filter { seen.insert($0).inserted }.compactMap { parsed[$0] }
        guard ids.isEmpty || !tweets.isEmpty else { throw XClientError.invalidResponse }
        page = XTimelinePage(tweets: tweets, nextCursor: nextCursor)
    }

    private static func instructions(in json: [String: Any]) -> [[String: Any]]? {
        let paths = [
            ["data", "home", "home_timeline_urt", "instructions"],
            ["data", "home_timeline", "home_timeline_urt", "instructions"],
            ["data", "user", "result", "timeline_v2", "timeline", "instructions"],
            ["data", "user", "result", "timeline", "timeline", "instructions"],
            ["data", "user_result_by_screen_name", "result", "profile_user_originals_timeline", "timeline", "instructions"],
            ["data", "user_result_by_screen_name", "result", "timeline", "timeline", "instructions"],
            ["data", "user_result_by_rest_id", "result", "profile_user_originals_timeline", "timeline", "instructions"],
            ["data", "threaded_conversation_with_injections_v2", "instructions"],
            ["data", "threaded_conversation_with_injections", "instructions"]
        ]
        for path in paths {
            var value: Any = json
            for key in path { value = (value as? [String: Any])?[key] ?? NSNull() }
            if let instructions = value as? [[String: Any]] { return instructions }
        }
        return nil
    }

    private static func isPromoted(_ object: [String: Any]) -> Bool {
        object["promotedMetadata"] != nil || object["promoted_metadata"] != nil
            || ((object["entryId"] ?? object["entry_id"]) as? String)?.hasPrefix("promoted-") == true
    }
}
