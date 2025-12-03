import Foundation

// Simple container for the Twitter account cookies/headers that were previously in accounts.json
private struct TwitterAccount {
    let username: String
    let headers: [String: String]
    let cookies: [String: String]
    let userAgent: String
    let active: Bool

    func cookieHeader() -> String {
        cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
    }

    func authHeaders() -> [String: String] {
        var result: [String: String] = [
            "accept": "*/*",
            "accept-encoding": "gzip, deflate, br",
            "accept-language": "en-US,en;q=0.9",
            "user-agent": userAgent,
            "content-type": "application/json",
        ]

        headers.forEach { key, value in
            result[key.lowercased()] = value
        }

        if let ct0 = cookies["ct0"] {
            result["x-csrf-token"] = ct0
        }

        if let auth = headers.first(where: { $0.key.lowercased() == "authorization" })?.value {
            result["authorization"] = auth
        }

        result["cookie"] = cookieHeader()
        return result
    }

    // Stubs copied from twscrape-serverless/accounts.json
    static let stubs: [TwitterAccount] = [
        TwitterAccount(
            username: "ZabirRaihan6",
            headers: [
                "accept": "*/*",
                "accept-encoding": "gzip, deflate",
                "connection": "keep-alive",
                "user-agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
                "content-type": "application/json",
                "authorization": "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA",
                "x-twitter-active-user": "yes",
                "x-twitter-client-language": "en",
                "x-guest-token": "1944317346782539966",
                "x-csrf-token": "691c191ecb6e6c2ccc9db7229633768b9ae5a2ae66e32c1a29eab0fc66359188d4a25f769e86361bb47fd23bc4e69898ed6d2205f7651471362ac596fa10220704fee535b573aa63bdb3819b108e53dc",
                "x-twitter-auth-type": "OAuth2Session"
            ],
            cookies: [
                "guest_id_marketing": "v1%3A175239635379340338",
                "guest_id_ads": "v1%3A175239635379340338",
                "personalization_id": "\"v1_lOnNL9itGt3j8EBvdRICww==\"",
                "guest_id": "v1%3A175239635379340338",
                "__cf_bm": "cjwW6uWkw24xlsIQAKG49wnELTn4z.oHIgxGDzd0Nos-1752396353-1.0.1.1-tiaNrbvdMgavE1MJ6KOBjytCG7YcSr4upfcqMSOb5tFMJsVhWeyPdbjxreXX65rO8cM37Jz7BwDk11Q.eO47PJ_cd18TCkTZFtlNY4MEvXA",
                "kdt": "Ae8cgmkuzMpFoWxDpYZ8bPu5tSjYdgapQ9rwPyky",
                "twid": "\"u=1920525919464329216\"",
                "ct0": "691c191ecb6e6c2ccc9db7229633768b9ae5a2ae66e32c1a29eab0fc66359188d4a25f769e86361bb47fd23bc4e69898ed6d2205f7651471362ac596fa10220704fee535b573aa63bdb3819b108e53dc",
                "auth_token": "6180de3ff8cb16b73396f797bf6a497c23a44433",
                "att": "1-UJjl7HjBjvW551cBvutDzrZsCNyKh9zCCWb0RLCc"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
            active: true
        ),
        TwitterAccount(
            username: "zabir.raihan8@gmail.com",
            headers: [:],
            cookies: [
                "auth_token": "d6e6e2131bf74b6ced768de7217186c910a77d26",
                "ct0": "d159fa38cd9ca7c075b422b6657452346d4881356ad0cbf4fd4784a4e02ecc193abe9e80d0e9df8fbf1dbd7880401b674a5a0987977eda69825ca05d32b96c42967a7a900d767d3843a3274a9242c154"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
            active: true
        ),
        TwitterAccount(
            username: "Davidd609198688",
            headers: [:],
            cookies: [
                "auth_token": "962d2da2540ea664e3bba85d9b5d0833d097aac1",
                "ct0": "4e897f6321f387edf99bc2e1fc7e3ccd0a15337dafb8aaca44224c2ea60e6b4af85e8fa61abca992c24204748e9edbe744671aec566b5b1e84728e90d56e0419099dbdc796f922e2b0d8cf4fe6331bea"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1",
            active: true
        ),
        TwitterAccount(
            username: "RaihanZabi14335",
            headers: [:],
            cookies: [
                "auth_token": "d6e6e2131bf74b6ced768de7217186c910a77d26",
                "ct0": "d159fa38cd9ca7c075b422b6657452346d4881356ad0cbf4fd4784a4e02ecc193abe9e80d0e9df8fbf1dbd7880401b674a5a0987977eda69825ca05d32b96c42967a7a900d767d3843a3274a9242c154"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1",
            active: true
        )
    ]
}

// Minimal Swift re-implementation of the Python twscrape list timeline fetch
struct TWScrapeClient {
    static let shared = TWScrapeClient()

    private let gqlURL = "https://x.com/i/api/graphql/BkauSnPUDQTeeJsxq17opA/ListLatestTweetsTimeline"
    private let listId = "1661518034639659009" // DEFAULT_LIST_ID from Python config
    private let features: [String: Any] = [
        "articles_preview_enabled": false,
        "c9s_tweet_anatomy_moderator_badge_enabled": true,
        "communities_web_enable_tweet_community_results_fetch": true,
        "creator_subscriptions_quote_tweet_preview_enabled": false,
        "creator_subscriptions_tweet_preview_api_enabled": true,
        "freedom_of_speech_not_reach_fetch_enabled": true,
        "graphql_is_translatable_rweb_tweet_is_translatable_enabled": true,
        "longform_notetweets_consumption_enabled": true,
        "longform_notetweets_inline_media_enabled": true,
        "longform_notetweets_rich_text_read_enabled": true,
        "responsive_web_edit_tweet_api_enabled": true,
        "responsive_web_enhance_cards_enabled": false,
        "responsive_web_graphql_exclude_directive_enabled": true,
        "responsive_web_graphql_skip_user_profile_image_extensions_enabled": false,
        "responsive_web_graphql_timeline_navigation_enabled": true,
        "responsive_web_media_download_video_enabled": false,
        "responsive_web_twitter_article_tweet_consumption_enabled": true,
        "rweb_tipjar_consumption_enabled": true,
        "rweb_video_timestamps_enabled": true,
        "standardized_nudges_misinfo": true,
        "tweet_awards_web_tipping_enabled": false,
        "tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled": true,
        "tweet_with_visibility_results_prefer_gql_media_interstitial_enabled": false,
        "tweetypie_unmention_optimization_enabled": true,
        "verified_phone_label_enabled": false,
        "view_counts_everywhere_api_enabled": true,
        "responsive_web_grok_analyze_button_fetch_trends_enabled": false,
        "premium_content_api_read_enabled": false,
        "profile_label_improvements_pcf_label_in_post_enabled": false,
        "responsive_web_grok_share_attachment_enabled": false,
        "responsive_web_grok_analyze_post_followups_enabled": false,
        "responsive_web_grok_image_annotation_enabled": false,
        "responsive_web_grok_analysis_button_from_backend": false,
        "responsive_web_jetfuel_frame": false,
        "rweb_video_screen_enabled": true,
        "responsive_web_grok_show_grok_translated_post": true
    ]

    func fetchListTimeline(limit: Int = 120) async throws -> [Tweet] {
        guard let account = TwitterAccount.stubs.first(where: { $0.active }) else {
            throw NetworkError.invalidURL
        }

        var all: [Tweet] = []
        var cursor: String?
        let pageSize = 50
        var page = 0

        repeat {
            page += 1
            var components = URLComponents(string: gqlURL)
            var variables: [String: Any] = ["listId": listId, "count": pageSize]
            if let cursor = cursor { variables["cursor"] = cursor }
            components?.queryItems = [
                URLQueryItem(name: "variables", value: Self.encodeQueryParam(variables)),
                URLQueryItem(name: "features", value: Self.encodeQueryParam(features)),
                URLQueryItem(name: "fieldToggles", value: Self.encodeQueryParam(["withArticleRichContentState": false]))
            ]

            guard let url = components?.url else { throw NetworkError.invalidURL }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = account.authHeaders()

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.badServerResponse
            }

            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let json = jsonObject as? [String: Any] else {
                throw NetworkError.decodingError
            }

            let newTweets = GraphQLTweetParser.parseTweets(from: json, limit: -1)
            let existingIds = Set(all.map { $0.id })
            let deduped = newTweets.filter { !existingIds.contains($0.id) }
            all.append(contentsOf: deduped)

            cursor = findCursor(in: json, type: "Bottom")
        } while cursor != nil && all.count < limit && page < 10

        if all.count > limit {
            all = Array(all.prefix(limit))
        }

        return all
    }

    private static func encodeQueryParam(_ value: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

private func findCursor(in obj: Any, type: String) -> String? {
    guard let dict = obj as? [String: Any] else {
        if let arr = obj as? [Any] {
            for item in arr {
                if let val = findCursor(in: item, type: type) {
                    return val
                }
            }
        }
        return nil
    }

    if let cursorType = dict["cursorType"] as? String,
       cursorType == type,
       let value = dict["value"] as? String {
        return value
    }

    for value in dict.values {
        if let found = findCursor(in: value, type: type) {
            return found
        }
    }

    return nil
}

// MARK: - Parser (ported from twscrape)

private struct OldRepresentation {
    let tweets: [String: [String: Any]]
    let users: [String: [String: Any]]
}

private enum GraphQLTweetParser {
    static func parseTweets(from json: [String: Any], limit: Int = -1) -> [Tweet] {
        let rep = toOldRepresentation(json)
        var results: [Tweet] = []

        for (idx, (_, value)) in rep.tweets.enumerated() {
            if limit != -1 && idx >= limit { break }
            if let tweet = parseTweet(from: value, context: rep, visited: Set<Int>()) {
                results.append(tweet)
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
        guard let userId = obj["user_id_str"] as? String, let userObj = context.users[userId],
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
        let dateString = isoDate(from: createdAt)

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
            date: dateString,
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
            created: isoDate(from: createdAt),
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
        guard let startRange = source.range(of: ">"), let endRange = source.range(of: "<", range: startRange.upperBound..<source.endIndex) else {
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

    private static func isoDate(from source: String) -> String {
        guard !source.isEmpty else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let date = formatter.date(from: source) {
            return ISO8601DateFormatter().string(from: date)
        }
        return source
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
    let date: String
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
        self.formattedDate = payload.date.formattedRelativeDate()
        self.formattedReplyCount = payload.replyCount.formattedCount()
        self.formattedRetweetCount = payload.retweetCount.formattedCount()
        self.formattedLikeCount = payload.likeCount.formattedCount()
        self.formattedQuoteCount = payload.quoteCount.formattedCount()
        self.parsedContent = String.parseContent(payload.rawContent)
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
        self.formattedDate = tweet.formattedDate
        self.formattedReplyCount = tweet.formattedReplyCount
        self.formattedRetweetCount = tweet.formattedRetweetCount
        self.formattedLikeCount = tweet.formattedLikeCount
        self.formattedQuoteCount = tweet.formattedQuoteCount
        self.parsedContent = tweet.parsedContent
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
        self.formattedDate = payload.date.formattedRelativeDate()
        self.formattedReplyCount = payload.replyCount.formattedCount()
        self.formattedRetweetCount = payload.retweetCount.formattedCount()
        self.formattedLikeCount = payload.likeCount.formattedCount()
        self.formattedQuoteCount = payload.quoteCount.formattedCount()
        self.parsedContent = String.parseContent(payload.rawContent)
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
