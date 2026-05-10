import Foundation

struct TWScrapeParser {
    struct OldRepresentation {
        let tweets: [String: [String: Any]]
        let users: [String: [String: Any]]
    }

    static func parseTweets(from json: [String: Any], limit: Int = -1) -> [Tweet] {
        let rep = toOldRepresentation(json)
        var results: [Tweet] = []
        var ids = Set<Int>()

        for (_, value) in rep.tweets {
            guard limit == -1 || results.count < limit else { break }
            if let tweet = parseTweet(from: value, context: rep, visited: []) {
                if !ids.contains(tweet.id) {
                    ids.insert(tweet.id)
                    results.append(tweet)
                }
            }
        }

        return results
    }

    static func parseUsers(from json: [String: Any], limit: Int = -1) -> [User] {
        let rep = toOldRepresentation(json)
        var results: [User] = []
        var ids = Set<Int>()

        for (_, value) in rep.users {
            guard limit == -1 || results.count < limit else { break }
            if let user = parseUser(value) {
                if !ids.contains(user.id) {
                    ids.insert(user.id)
                    results.append(user)
                }
            }
        }

        return results
    }

    private static func parseTweet(
        from obj: [String: Any],
        context: OldRepresentation,
        visited: Set<Int>,
        asRetweet: Bool = false
    ) -> Tweet? {
        guard let userId = obj["user_id_str"] as? String,
              let userObj = context.users[userId],
              let user = parseUser(userObj),
              let idStr = obj["id_str"] as? String,
              let id = Int(idStr)
        else {
            return nil
        }

        var visited = visited
        if visited.contains(id) { return nil }
        visited.insert(id)

        let url = "https://x.com/\(user.username)/status/\(idStr)"
        let createdAt = (obj["created_at"] as? String) ?? ""
        let date = parseDate(from: createdAt)

        let replyCount = obj["reply_count"] as? Int ?? 0
        let retweetCount = obj["retweet_count"] as? Int ?? 0
        let likeCount = obj["favorite_count"] as? Int ?? 0
        let quoteCount = obj["quote_count"] as? Int ?? 0
        let conversationIdStr = (obj["conversation_id_str"] as? String) ?? idStr
        let conversationId = Int(conversationIdStr) ?? id

        let hashtags = ((valueForPath("entities.hashtags", in: obj) as? [[String: Any]]) ?? [])
            .compactMap { $0["text"] as? String }

        let rawContent = valueForPath("note_tweet.note_tweet_results.result.text", in: obj) as? String
            ?? obj["full_text"] as? String
            ?? obj["text"] as? String
            ?? ""

        let links = parseLinks(obj)
        let media = parseMedia(obj)
        let place = parsePlace(obj["place"] as? [String: Any])
        let inReplyToTweetIdStr = obj["in_reply_to_status_id_str"] as? String
        let inReplyToTweetId = inReplyToTweetIdStr.flatMap { Int($0) }
        let inReplyToUser = parseReplyUser(obj, context: context)
        let source = obj["source"] as? String
        let sourceUrl = parseSourceUrl(source)
        let sourceLabel = parseSourceLabel(source)
        let viewCount = firstInt(["ext_views.count", "views.count"], in: obj)

        let rtId = firstString(["retweeted_status_id_str", "retweeted_status_result.result.rest_id", "retweeted_status_result.result.tweet.rest_id"], in: obj)
        let qtId = firstString(["quoted_status_id_str", "quoted_status_result.result.rest_id", "quoted_status_result.result.tweet.rest_id"], in: obj)

        let retweetedTweet: Retweet? = {
            guard !asRetweet, let rid = rtId, let rtObj = context.tweets[rid] else { return nil }
            guard let rt = parseTweet(from: rtObj, context: context, visited: visited, asRetweet: true) else { return nil }
            return Retweet(from: rt)
        }()

        let quotedTweet: Retweet? = {
            guard !asRetweet, let qid = qtId, let qtObj = context.tweets[qid] else { return nil }
            guard let qt = parseTweet(from: qtObj, context: context, visited: visited, asRetweet: true) else { return nil }
            return Retweet(from: qt)
        }()

        let payload = TweetPayload(
            id: id,
            url: url,
            date: date,
            user: user,
            rawContent: rawContent,
            replyCount: replyCount,
            retweetCount: retweetCount,
            likeCount: likeCount,
            quoteCount: quoteCount,
            conversationId: conversationId,
            conversationIdStr: conversationIdStr,
            hashtags: hashtags,
            links: links,
            media: media,
            viewCount: viewCount,
            retweetedTweet: retweetedTweet,
            quotedTweet: quotedTweet,
            place: place,
            inReplyToTweetId: inReplyToTweetId,
            inReplyToTweetIdStr: inReplyToTweetIdStr,
            inReplyToUser: inReplyToUser,
            source: source,
            sourceUrl: sourceUrl,
            sourceLabel: sourceLabel
        )

        if asRetweet {
            return Tweet(from: Retweet(from: payload))
        } else {
            return Tweet(from: payload)
        }
    }

    private static func parseUser(_ obj: [String: Any]) -> User? {
        guard let idStr = obj["id_str"] as? String,
              let id = Int(idStr),
              let username = obj["screen_name"] as? String,
              let displayName = obj["name"] as? String,
              let description = obj["description"] as? String,
              let createdAt = obj["created_at"] as? String
        else {
            return nil
        }

        let url = "https://x.com/\(username)"
        let followersCount = obj["followers_count"] as? Int ?? 0
        let friendsCount = obj["friends_count"] as? Int ?? 0
        let statusesCount = obj["statuses_count"] as? Int ?? 0
        let location = obj["location"] as? String
        let profileImageUrl = obj["profile_image_url_https"] as? String ?? ""
        let profileBannerUrl = obj["profile_banner_url"] as? String
        let verified = obj["verified"] as? Bool
        let blue = obj["is_blue_verified"] as? Bool
        let links = parseDescriptionLinks(obj)
        let pinnedIds = (obj["pinned_tweet_ids_str"] as? [String] ?? []).compactMap { Int($0) }

        return User(
            id: id,
            url: url,
            username: username,
            displayname: displayName,
            rawDescription: description,
            created: parseDate(from: createdAt),
            followersCount: followersCount,
            friendsCount: friendsCount,
            statusesCount: statusesCount,
            location: location,
            profileImageUrl: profileImageUrl,
            profileBannerUrl: profileBannerUrl,
            verified: verified,
            blue: blue,
            descriptionLinks: links,
            pinnedIds: pinnedIds
        )
    }

    private static func parseDescriptionLinks(_ obj: [String: Any]) -> [Link] {
        let paths = ["entities.description.urls", "entities.url.urls"]
        return paths.flatMap { path -> [Link] in
            let entries = valueForPath(path, in: obj) as? [[String: Any]] ?? []
            return entries.compactMap { Link($0) }
        }
    }

    private static func parseLinks(_ obj: [String: Any]) -> [Link] {
        let paths = ["entities.urls", "note_tweet.note_tweet_results.result.entity_set.urls"]
        return paths.flatMap { path -> [Link] in
            let entries = valueForPath(path, in: obj) as? [[String: Any]] ?? []
            return entries.compactMap { Link($0) }
        }
    }

    private static func parseMedia(_ obj: [String: Any]) -> Media? {
        guard let entities = valueForPath("extended_entities.media", in: obj) as? [[String: Any]], !entities.isEmpty else {
            return nil
        }

        var photos: [Photo] = []
        var videos: [Video] = []
        var animated: [AnimatedMedia] = []

        for entry in entities {
            guard let type = entry["type"] as? String else { continue }
            switch type {
            case "photo":
                if let url = entry["media_url_https"] as? String {
                    photos.append(Photo(url: url))
                }
            case "video":
                let thumb = entry["media_url_https"] as? String ?? ""
                let variants = (entry["video_info"] as? [String: Any])?["variants"] as? [[String: Any]] ?? []
                let parsedVariants = variants.compactMap { variant -> VideoVariant? in
                    guard let url = variant["url"] as? String,
                          let type = variant["content_type"] as? String else { return nil }
                    let bitrate = variant["bitrate"] as? Int
                    return VideoVariant(contentType: type, bitrate: bitrate, url: url)
                }
                let duration = (entry["video_info"] as? [String: Any])?["duration_millis"] as? Int ?? 0
                let views = (entry["mediaStats"] as? [String: Any])?["viewCount"] as? Int
                videos.append(Video(thumbnailUrl: thumb, variants: parsedVariants, duration: duration, views: views))
            case "animated_gif":
                let thumb = entry["media_url_https"] as? String ?? ""
                if let url = ((entry["video_info"] as? [String: Any])?["variants"] as? [[String: Any]])?.first?["url"] as? String {
                    animated.append(AnimatedMedia(thumbnailUrl: thumb, videoUrl: url))
                }
            default:
                continue
            }
        }

        return Media(photos: photos.isEmpty ? nil : photos,
                     videos: videos.isEmpty ? nil : videos,
                     animated: animated.isEmpty ? nil : animated)
    }

    private static func parsePlace(_ obj: [String: Any]?) -> Place? {
        guard let obj = obj,
              let id = obj["id"] as? String,
              let fullName = obj["full_name"] as? String,
              let name = obj["name"] as? String,
              let type = obj["place_type"] as? String,
              let country = obj["country"] as? String,
              let countryCode = obj["country_code"] as? String
        else { return nil }

        return Place(id: id, fullName: fullName, name: name, type: type, country: country, countryCode: countryCode)
    }

    private static func parseReplyUser(_ obj: [String: Any], context: OldRepresentation) -> InReplyToUser? {
        guard let userId = obj["in_reply_to_user_id_str"] as? String else { return nil }

        if let userObj = context.users[userId] {
            return InReplyToUser(id: Int(userId) ?? 0,
                                 username: userObj["screen_name"] as? String ?? "",
                                 displayname: userObj["name"] as? String ?? "")
        }

        let mentions = valueForPath("entities.user_mentions", in: obj) as? [[String: Any]] ?? []
        if let mention = mentions.first(where: { ($0["id_str"] as? String) == userId }) {
            return InReplyToUser(
                id: Int(userId) ?? 0,
                username: mention["screen_name"] as? String ?? "",
                displayname: mention["name"] as? String ?? ""
            )
        }

        return nil
    }

    private static func parseSourceUrl(_ source: String?) -> String? {
        guard let source = source else { return nil }
        guard let startRange = source.range(of: "href=\"") else { return nil }
        let substring = source[startRange.upperBound...]
        guard let endRange = substring.range(of: "\"") else { return nil }
        return String(substring[..<endRange.lowerBound])
    }

    private static func parseSourceLabel(_ source: String?) -> String? {
        guard let source = source else { return nil }
        guard let startRange = source.range(of: ">"),
              let endRange = source.range(of: "<", range: startRange.upperBound..<source.endIndex) else {
            return nil
        }
        return String(source[startRange.upperBound..<endRange.lowerBound])
    }

    private static func valueForPath(_ path: String, in dict: [String: Any]) -> Any? {
        let parts = path.split(separator: ".").map(String.init)
        var current: Any? = dict
        for key in parts {
            if let d = current as? [String: Any] {
                current = d[key]
            } else if let arr = current as? [[String: Any]], let index = Int(key), index < arr.count {
                current = arr[index]
            } else {
                return nil
            }
        }
        return current
    }

    private static func firstString(_ paths: [String], in dict: [String: Any]) -> String? {
        for path in paths {
            if let val = valueForPath(path, in: dict) as? String, !val.isEmpty {
                return val
            }
        }
        return nil
    }

    private static func firstInt(_ paths: [String], in dict: [String: Any]) -> Int? {
        for path in paths {
            if let val = valueForPath(path, in: dict) as? Int {
                return val
            }
            if let val = valueForPath(path, in: dict) as? String, let intVal = Int(val) {
                return intVal
            }
        }
        return nil
    }

    private static func parseDate(from source: String) -> Date {
        TweetDateParser.parse(source) ?? Date()
    }

    private static func toOldRepresentation(_ obj: [String: Any]) -> OldRepresentation {
        var typed: [String: [[String: Any]]] = [:]
        collectTypedObjects(obj, into: &typed)

        var tweets: [String: [String: Any]] = [:]
        for tw in typed["Tweet"] ?? [] where tw["legacy"] != nil {
            let converted = toOldObject(tw)
            if let id = converted["id_str"] as? String {
                tweets[id] = converted
            }
        }

        for tw in typed["TweetWithVisibilityResults"] ?? [] {
            if let tweetObj = tw["tweet"] as? [String: Any], tweetObj["legacy"] != nil {
                let converted = toOldObject(tweetObj)
                if let id = converted["id_str"] as? String {
                    tweets[id] = converted
                }
            }
        }

        var users: [String: [String: Any]] = [:]
        for user in typed["User"] ?? [] where user["legacy"] != nil {
            let converted = toOldObject(user)
            if let id = converted["id_str"] as? String {
                users[id] = converted
            }
        }

        return OldRepresentation(tweets: tweets, users: users)
    }

    private static func collectTypedObjects(_ obj: Any, into storage: inout [String: [[String: Any]]]) {
        guard let dict = obj as? [String: Any] else { return }

        if let typeName = dict["__typename"] as? String {
            storage[typeName, default: []].append(dict)
        }

        for value in dict.values {
            if let child = value as? [String: Any] {
                collectTypedObjects(child, into: &storage)
            } else if let arr = value as? [Any] {
                arr.forEach { collectTypedObjects($0, into: &storage) }
            }
        }
    }

    private static func toOldObject(_ obj: [String: Any]) -> [String: Any] {
        var merged = obj
        if let legacy = obj["legacy"] as? [String: Any] {
            for (key, value) in legacy {
                merged[key] = value
            }
        }

        if let restIdStr = obj["rest_id"] as? String {
            merged["id_str"] = restIdStr
            merged["id"] = Int(restIdStr)
        } else if let restIdInt = obj["rest_id"] as? Int {
            merged["id_str"] = String(restIdInt)
            merged["id"] = restIdInt
        }

        merged["legacy"] = nil
        return merged
    }
}

private struct TweetPayload {
    let id: Int
    let url: String
    let date: Date
    let user: User
    let rawContent: String
    let replyCount: Int
    let retweetCount: Int
    let likeCount: Int
    let quoteCount: Int
    let conversationId: Int
    let conversationIdStr: String
    let hashtags: [String]
    let links: [Link]
    let media: Media?
    let viewCount: Int?
    let retweetedTweet: Retweet?
    let quotedTweet: Retweet?
    let place: Place?
    let inReplyToTweetId: Int?
    let inReplyToTweetIdStr: String?
    let inReplyToUser: InReplyToUser?
    let source: String?
    let sourceUrl: String?
    let sourceLabel: String?
}

private extension Tweet {
    init(from payload: TweetPayload) {
        self.id = payload.id
        self.url = payload.url
        self.date = payload.date
        self.user = payload.user
        self.rawContent = payload.rawContent
        self.replyCount = payload.replyCount
        self.retweetCount = payload.retweetCount
        self.likeCount = payload.likeCount
        self.quoteCount = payload.quoteCount
        self.conversationId = payload.conversationId
        self.conversationIdStr = payload.conversationIdStr
        self.hashtags = payload.hashtags
        self.links = payload.links
        self.media = payload.media
        self.viewCount = payload.viewCount
        self.retweetedTweet = payload.retweetedTweet
        self.quotedTweet = payload.quotedTweet
        self.place = payload.place
        self.inReplyToTweetId = payload.inReplyToTweetId
        self.inReplyToTweetIdStr = payload.inReplyToTweetIdStr
        self.inReplyToUser = payload.inReplyToUser
        self.source = payload.source
        self.sourceUrl = payload.sourceUrl
        self.sourceLabel = payload.sourceLabel
    }
}

private extension Retweet {
    init(from tweet: Tweet) {
        self.id = tweet.id
        self.url = tweet.url
        self.date = tweet.date
        self.user = tweet.user
        self.rawContent = tweet.rawContent
        self.replyCount = tweet.replyCount
        self.retweetCount = tweet.retweetCount
        self.likeCount = tweet.likeCount
        self.quoteCount = tweet.quoteCount
        self.conversationId = tweet.conversationId
        self.conversationIdStr = tweet.conversationIdStr
        self.hashtags = tweet.hashtags
        self.links = tweet.links
        self.media = tweet.media
        self.viewCount = tweet.viewCount
        self.place = tweet.place
        self.inReplyToTweetId = tweet.inReplyToTweetId
        self.inReplyToTweetIdStr = tweet.inReplyToTweetIdStr
        self.inReplyToUser = tweet.inReplyToUser
        self.source = tweet.source
        self.sourceUrl = tweet.sourceUrl
        self.sourceLabel = tweet.sourceLabel
    }

    init(from payload: TweetPayload) {
        self.id = payload.id
        self.url = payload.url
        self.date = payload.date
        self.user = payload.user
        self.rawContent = payload.rawContent
        self.replyCount = payload.replyCount
        self.retweetCount = payload.retweetCount
        self.likeCount = payload.likeCount
        self.quoteCount = payload.quoteCount
        self.conversationId = payload.conversationId
        self.conversationIdStr = payload.conversationIdStr
        self.hashtags = payload.hashtags
        self.links = payload.links
        self.media = payload.media
        self.viewCount = payload.viewCount
        self.place = payload.place
        self.inReplyToTweetId = payload.inReplyToTweetId
        self.inReplyToTweetIdStr = payload.inReplyToTweetIdStr
        self.inReplyToUser = payload.inReplyToUser
        self.source = payload.source
        self.sourceUrl = payload.sourceUrl
        self.sourceLabel = payload.sourceLabel
    }
}

private extension Link {
    init?(_ obj: [String: Any]) {
        guard let expanded = obj["expanded_url"] as? String ?? obj["url"] as? String else {
            return nil
        }
        let text = obj["display_url"] as? String
        let tco = obj["url"] as? String
        self.url = expanded
        self.text = text
        self.tcourl = tco
    }
}
