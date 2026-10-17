import Foundation

/// All X calls use the signed-in account's web session. No API credentials are bundled.
@MainActor
struct XClient {
    static let shared = XClient()

    private let session: URLSession
    private let registry = XOperationRegistry.shared
    private let sessionStore = XSessionStore.shared

    private init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration, delegate: XRedirectPolicy(), delegateQueue: nil)
    }

    func verify(credentials: XCredentials) async throws -> XAccount {
        let json = try await perform("viewerQuery", variables: [:], credentials: credentials)
        guard let viewer = (json["data"] as? [String: Any])?["viewer"] as? [String: Any],
              let results = viewer["user_results"] as? [String: Any],
              let user = results["result"] as? [String: Any],
              let id = (user["rest_id"] as? String).flatMap(Int.init),
              let core = user["core"] as? [String: Any],
              let username = core["screen_name"] as? String, !username.isEmpty,
              let name = core["name"] as? String else { throw XClientError.sessionExpired }
        return XAccount(id: id, username: username, displayName: name,
                        profileImageURL: (user["avatar"] as? [String: Any])?["image_url"] as? String)
    }

    func fetchFeed(filter: FeedFilter, cursor: String? = nil) async throws -> XTimelinePage {
        let operation: String
        var variables: [String: Any] = ["count": 20]
        switch filter {
        case .recent, .popular:
            operation = "HomeLatestTimeline"
            variables["enableRanking"] = filter == .popular
            variables["includePromotedContent"] = true
        case .forYou:
            operation = "HomeTimeline"
            variables["includePromotedContent"] = true
        }
        if let cursor { variables["cursor"] = cursor }
        else { variables["requestContext"] = "launch" }
        return try XTimelineResponse(json: await perform(operation, variables: variables)).page
    }

    func fetchProfile(userID: Int, username: String? = nil) async throws -> XProfile {
        let json: [String: Any]
        if let username, !username.isEmpty {
            json = try await perform("UserByScreenName", variables: ["screenName": username, "withSafetyModeUserFields": true])
        } else {
            json = try await perform("UserByRestId", variables: ["userId": String(userID), "withSafetyModeUserFields": true])
        }
        guard let data = json["data"] as? [String: Any],
              let result = (data["user_result_by_screen_name"] as? [String: Any])?["result"] as? [String: Any]
                ?? (data["user"] as? [String: Any])?["result"] as? [String: Any],
              let normalized = XPayloadNormalizer.normalize(["user": result]) as? [String: Any],
              let user = XPostParser.parseUsers(from: normalized).first(where: { $0.id == userID }) else {
            throw XClientError.invalidResponse
        }
        let perspectives = result["relationship_perspectives"] as? [String: Any] ?? [:]
        let legacy = result["legacy"] as? [String: Any] ?? [:]
        guard let following = perspectives["following"] as? Bool ?? result["following"] as? Bool ?? legacy["following"] as? Bool else {
            // An unknown relationship must never be displayed as "not following".
            if userID == sessionStore.account?.id { return XProfile(user: user, relationship: XRelationship(isFollowing: false)) }
            throw XClientError.invalidResponse
        }
        let requested = perspectives["follow_request_sent"] as? Bool
            ?? result["follow_request_sent"] as? Bool ?? legacy["follow_request_sent"] as? Bool ?? false
        return XProfile(user: user, relationship: XRelationship(isFollowing: following, isRequested: requested))
    }

    func fetchUserTweets(userID: Int, username: String? = nil) async throws -> [Tweet] {
        var variables: [String: Any] = [
            "userId": String(userID), "count": 20, "includePromotedContent": true,
            "withVoice": true, "withV2Timeline": true, "sortByMostLiked": false, "cursor": NSNull()
        ]
        if let username { variables["screenName"] = username }
        return try XTimelineResponse(json: await perform("UserTweets", variables: variables)).tweets
    }

    func fetchReplies(tweetID: Int) async throws -> [Tweet] {
        let json = try await perform("TweetDetail", variables: [
            "focalTweetId": String(tweetID), "referrer": "tweet", "withFocalTweet": true,
            "cursor": NSNull(), "rankingMode": "Relevance"
        ])
        return try XTimelineResponse(json: json).tweets.filter { $0.inReplyToTweetId == tweetID }
    }

    func searchTweets(query: String) async throws -> [Tweet] {
        let pages = try await search(query: query, product: "Latest")
        var seen = Set<Int>()
        return pages.flatMap(\.tweets).filter { seen.insert($0.id).inserted }
    }

    func searchUsers(query: String) async throws -> [User] {
        let pages = try await search(query: query, product: "People")
        var seen = Set<Int>()
        return pages.flatMap(\.users).filter { seen.insert($0.id).inserted }
    }

    func setFollowing(userID: Int, following: Bool, username: String? = nil) async throws -> XRelationship {
        guard userID != sessionStore.account?.id else { throw XClientError.apiError }
        let revision = sessionStore.revision
        let json = try await perform(following ? "followUserMutation" : "unfollowUserMutation",
                                     variables: ["targetUserId": String(userID)], retryDiscovery: false)
        let field = following ? "follow_user" : "unfollow_user"
        let expected = following ? "FollowSuccessResult" : "UnfollowSuccessResult"
        guard let result = (json["data"] as? [String: Any])?[field] as? [String: Any],
              result["__typename"] as? String == expected else { throw XClientError.apiError }
        try Task.checkCancellation()
        guard revision == sessionStore.revision else { throw CancellationError() }
        sessionStore.followingDidChange()
        // Protected accounts may return a request instead of an immediate follow.
        let relationship = try await fetchProfile(userID: userID, username: username).relationship
        return relationship
    }

    private func search(query: String, product: String) async throws -> [XSearchResponse] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        var pages: [XSearchResponse] = []
        var cursor: String?
        var seen = Set<String>()
        for _ in 0..<2 {
            var variables: [String: Any] = ["rawQuery": query, "product": product, "querySource": "typed_query", "count": 20, "withMediaGridTweet": false]
            if let cursor { variables["cursor"] = cursor }
            let json = try await perform("SearchByRawQuery", variables: variables)
            let page = try XSearchResponse(json: json)
            pages.append(page)
            guard let next = page.nextCursor, seen.insert(next).inserted else { break }
            cursor = next
        }
        return pages
    }

    private func perform(_ name: String, variables: [String: Any], credentials override: XCredentials? = nil,
                         retryDiscovery: Bool = true) async throws -> [String: Any] {
        try Task.checkCancellation()
        guard let operation = registry.operation(named: name) else { throw XClientError.operationUnavailable }
        let revision = sessionStore.revision
        guard let credentials = override ?? sessionStore.credentials, credentials.isValid else { throw XClientError.signedOut }
        let request = try Self.request(operation: operation, variables: variables, credentials: credentials)
        let (body, response) = try await session.data(for: request)
        try Task.checkCancellation()
        if override == nil, revision != sessionStore.revision { throw CancellationError() }
        guard let response = response as? HTTPURLResponse else { throw XClientError.invalidResponse }
        let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any]
        let codes = (json?["errors"] as? [[String: Any]] ?? []).compactMap { $0["code"] as? Int }
        if response.statusCode == 401 || codes.contains(where: [32, 89, 215, 239].contains) {
            if override == nil { sessionStore.expire(ifRevision: revision) }
            throw XClientError.sessionExpired
        }
        if response.statusCode == 429 || codes.contains(88) { throw XClientError.rateLimited }
        if [400, 404].contains(response.statusCode), retryDiscovery {
            await registry.refresh()
            try Task.checkCancellation()
            if override == nil, revision != sessionStore.revision { throw CancellationError() }
            return try await perform(name, variables: variables, credentials: override, retryDiscovery: false)
        }
        guard (200..<300).contains(response.statusCode) else { throw XClientError.httpStatus(response.statusCode) }
        guard let json else { throw XClientError.invalidResponse }
        if let errors = json["errors"] as? [Any], !errors.isEmpty { throw XClientError.apiError }
        return json
    }

    private static func request(operation: XOperation, variables: [String: Any], credentials: XCredentials) throws -> URLRequest {
        var variables = variables
        for (key, value) in operation.relayVariables { variables[key] = value }
        var payload: [String: Any] = ["variables": variables]
        if !operation.isRelay {
            payload["features"] = operation.features
            payload["fieldToggles"] = ["withArticleRichContentState": false, "withArticlePlainText": false]
        }
        var request = URLRequest(url: operation.endpoint, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = operation.method
        request.httpShouldHandleCookies = false
        request.allHTTPHeaderFields = credentials.headers
        if operation.isRelay { request.setValue("Tia", forHTTPHeaderField: "x-twitter-auth-type") }
        if operation.method == "GET" {
            var components = URLComponents(url: operation.endpoint, resolvingAgainstBaseURL: false)
            components?.queryItems = try payload.map { key, value in
                let encoded = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
                return URLQueryItem(name: key, value: String(decoding: encoded, as: UTF8.self))
            }
            guard let url = components?.url else { throw XClientError.invalidResponse }
            request.url = url
        } else {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        }
        return request
    }
}
