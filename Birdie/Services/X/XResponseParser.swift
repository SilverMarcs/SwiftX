import Foundation

nonisolated enum XResponseParser {
    static func home(_ json: JSONValue) throws -> TimelinePage {
        try timeline(json.at("data.home_timeline.home_timeline_urt"))
    }

    /// Walk timeline instructions, never the arbitrary object graph. Embedded
    /// quotes/reposts are decoded only as attachments to their owning post.
    static func timeline(_ value: JSONValue) throws -> TimelinePage {
        guard case .array(let instructions) = value["instructions"] else { throw XAPIError.responseChanged }
        var entries: [TimelineEntry] = []
        var cursor: String?
        var terminated = false

        for instruction in instructions {
            let type = instruction["__typename"].string ?? instruction["type"].string
            if type == "TimelineTerminateTimeline", instruction["direction"].string == "Bottom" {
                terminated = true
            }
            var rawEntries = instruction["entries"].array
            if !instruction["entry"].isNull { rawEntries.append(instruction["entry"]) }
            if type == "TimelineAddToModule" {
                let moduleID = instruction["module_entry_id"].string ?? instruction["moduleEntryId"].string ?? "module"
                for item in instruction["module_items"].array + instruction["moduleItems"].array {
                    if let entry = try moduleItem(item, moduleID: moduleID) { entries.append(entry) }
                }
            }
            for raw in rawEntries {
                let id = raw["entry_id"].string ?? raw["entryId"].string ?? ""
                let content = raw["content"]
                let cursorType = content["cursor_type"].string ?? content["cursorType"].string
                if cursorType == "Bottom" { cursor = content["value"].string }
                if content["__typename"].string == "TimelineTimelineModule" || !content["items"].isNull {
                    for item in content["items"].array {
                        if let entry = try moduleItem(item, moduleID: id) { entries.append(entry) }
                    }
                } else if let entry = try entry(content, id: id) {
                    if let replacedID = instruction["entry_id_to_replace"].string ?? instruction["entryIdToReplace"].string,
                       let index = entries.firstIndex(where: { $0.id == replacedID }) {
                        entries[index] = entry
                    } else {
                        entries.append(entry)
                    }
                }
            }
        }
        var ids = Set<String>()
        entries = entries.filter { ids.insert($0.post.id).inserted }
        return TimelinePage(entries: entries, nextCursor: terminated ? nil : cursor, isTerminated: terminated)
    }

    static func users(in timeline: JSONValue) -> [User] {
        var result: [User] = []
        var ids = Set<String>()
        for instruction in timeline["instructions"].array {
            for entry in instruction["entries"].array {
                let item = itemContent(entry["content"])
                if let user = user(item.at("user_results.result")), ids.insert(user.id).inserted { result.append(user) }
            }
        }
        return result
    }

    static func user(_ value: JSONValue) -> User? {
        guard let id = value["rest_id"].string,
              let username = value.at("core.screen_name").string ?? value.at("legacy.screen_name").string else { return nil }
        let legacy = value["legacy"]
        return User(
            id: id,
            username: username,
            name: value.at("core.name").string ?? legacy["name"].string ?? username,
            bio: value.at("profile_bio.description").string ?? legacy["description"].string,
            followersCount: value.at("relationship_counts.followers").int ?? legacy["followers_count"].int,
            followingCount: value.at("relationship_counts.following").int ?? legacy["friends_count"].int,
            location: value.at("location.location").string ?? legacy["location"].string,
            avatarURL: (value.at("avatar.image_url").string ?? legacy["profile_image_url_https"].string).flatMap(URL.init(string:)),
            bannerURL: (value.at("profile_header.image_url").string ?? legacy["profile_banner_url"].string).flatMap(URL.init(string:)),
            isVerified: (value.at("verification.is_blue_verified").bool ?? value["is_blue_verified"].bool ?? false) || (legacy["verified"].bool ?? false),
            isLegacyVerified: legacy["verified"].bool ?? false,
            isFollowing: value.at("relationship_perspectives.following").bool ?? value["is_following"].bool ?? legacy["following"].bool,
            links: links(legacy.at("entities.description.urls").array + legacy.at("entities.url.urls").array)
        )
    }

    static func post(_ raw: JSONValue, depth: Int = 0) -> Post? {
        guard depth < 5 else { return nil }
        let value = raw["__typename"].string == "TweetWithVisibilityResults" ? raw["tweet"] : raw
        guard value["__typename"].string == "Tweet", let id = value["rest_id"].string,
              let author = user(value.at("core.user_results.result")) else { return nil }
        let legacy = value["legacy"]
        let details = value["details"]
        let counts = value["counts"]
        let note = value.at("note_tweet.note_tweet_results.result")
        let date: Date?
        if let milliseconds = details["created_at_ms"].number { date = Date(timeIntervalSince1970: milliseconds / 1_000) }
        else { date = legacy["created_at"].string.flatMap(parseDate) }
        var post = Post(id: id, user: author, date: date)
        post.text = note["text"].string ?? details["full_text"].string ?? legacy["full_text"].string ?? ""
        post.replyCount = counts["reply_count"].int ?? legacy["reply_count"].int ?? 0
        post.repostCount = counts["retweet_count"].int ?? legacy["retweet_count"].int ?? 0
        post.likeCount = counts["favorite_count"].int ?? legacy["favorite_count"].int ?? 0
        post.bookmarkCount = counts["bookmark_count"].int ?? legacy["bookmark_count"].int ?? 0
        post.viewCount = value.at("views.count").int
        post.replyToID = value.at("reply_to_results.rest_id").string ?? value.at("reply_to_results.result.rest_id").string
            ?? details["in_reply_to_status_id_str"].string ?? legacy["in_reply_to_status_id_str"].string
        post.links = links(note.at("entity_set.urls").array + value["url_entities"].array + legacy.at("entities.urls").array)
        post.media = media(value["media_entities2"].isNull ? legacy.at("extended_entities.media").array : value["media_entities2"].array)
        let quote = value.at("quoted_tweet_results.result").isNull ? value.at("quoted_status_result.result") : value.at("quoted_tweet_results.result")
        if let child = Self.post(quote, depth: depth + 1) { post.quote = .post(child) }
        let repost = legacy.at("retweeted_status_results.result").isNull ? legacy.at("retweeted_status_result.result") : legacy.at("retweeted_status_results.result")
        if let child = Self.post(repost, depth: depth + 1) { post.repost = .post(child) }
        return post
    }

    private static func itemContent(_ value: JSONValue) -> JSONValue {
        if !value["itemContent"].isNull { value["itemContent"] }
        else if !value["content"].isNull { value["content"] }
        else { value }
    }

    private static func entry(_ content: JSONValue, id: String, conversationID: String? = nil) throws -> TimelineEntry? {
        let item = itemContent(content)
        let result = item.at("tweet_results.result")
        guard let post = post(result) else {
            let type = result["__typename"].string
            if type == "Tweet" || type == "TweetWithVisibilityResults" { throw XAPIError.responseChanged }
            return nil
        }
        let context = content["social_context"].isNull ? item["socialContext"] : content["social_context"]
        return TimelineEntry(
            id: id.isEmpty ? post.id : id,
            post: post,
            context: context["text"].string ?? context.at("text.text").string ?? item.at("social_context.text").string,
            isPromoted: !item["promoted_metadata"].isNull || !item["promotedMetadata"].isNull,
            conversationID: conversationID
        )
    }

    private static func moduleItem(_ value: JSONValue, moduleID: String) throws -> TimelineEntry? {
        let id = value["entry_id"].string ?? value["entryId"].string ?? ""
        return try entry(value["item"], id: id.isEmpty ? "" : "\(moduleID)/\(id)", conversationID: moduleID)
    }

    private static func links(_ values: [JSONValue]) -> [PostLink] {
        var urls = Set<URL>()
        return values.compactMap { value in
            guard let text = value["expanded_url"].string ?? value["url"].string,
                  let url = URL(string: text), ["https", "http"].contains(url.scheme), urls.insert(url).inserted else { return nil }
            return PostLink(url: url, label: value["display_url"].string ?? url.host() ?? text)
        }
    }

    private static func media(_ values: [JSONValue]) -> Media? {
        var result = Media()
        for value in values {
            guard let url = value["media_url_https"].string else { continue }
            switch value["type"].string {
            case "photo": result.photos.append(Photo(url: url))
            case "video", "animated_gif":
                let variants = value.at("video_info.variants").array.compactMap { variant -> VideoVariant? in
                    guard let url = variant["url"].string, let contentType = variant["content_type"].string else { return nil }
                    return VideoVariant(contentType: contentType, bitrate: variant["bitrate"].int, url: url)
                }
                result.videos.append(Video(thumbnailUrl: url, variants: variants, duration: value.at("video_info.duration_millis").int, views: nil))
            default: break
            }
        }
        return result.photos.isEmpty && result.videos.isEmpty ? nil : result
    }

    private static func parseDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter.date(from: value)
    }
}
