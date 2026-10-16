import Foundation

@MainActor
final class XClient: TimelineLoading {
    static let shared = XClient(credentials: { XAuthStore.shared.session })

    private let credentials: () -> XSession
    private let session: URLSession

    init(credentials: @escaping () -> XSession, session: URLSession? = nil) {
        self.credentials = credentials
        if let session { self.session = session }
        else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.httpShouldSetCookies = false
            configuration.httpCookieStorage = nil
            self.session = URLSession(configuration: configuration)
        }
    }

    func home(cursor: String? = nil, seenIDs: [String] = [], refreshing: Bool = false) async throws -> TimelinePage {
        var variables: [String: Any] = [
            "count": 20,
            "seenTweetIds": Array(seenIDs.suffix(1_500)),
            "__relay_internal__pv__xclientsfeaturesappviewerisloggedinrelayprovider": true,
            "__relay_internal__pv__xclientsfeaturestranslationnoteautotranslationenabledrelayprovider": false
        ]
        if let cursor { variables["cursor"] = cursor }
        else { variables["requestContext"] = refreshing ? "ptr" : "launch" }
        return try XResponseParser.home(await request(.home, variables: variables))
    }

    func posts(userID: String) async throws -> [Post] {
        let json = try await request(.userPosts, variables: ["userId": userID, "count": 20, "includePromotedContent": true, "withVoice": true])
        let root = json.at("data.user.result")
        let timeline = root.at("timeline_v2.timeline").isNull ? root.at("timeline.timeline") : root.at("timeline_v2.timeline")
        return try XResponseParser.timeline(timeline).entries.map(\.post)
    }

    func profile(userID: String) async throws -> User {
        let json = try await request(.profile, variables: ["userId": userID, "withSafetyModeUserFields": true])
        guard let user = XResponseParser.user(json.at("data.user.result")) else { throw XAPIError.responseChanged }
        return user
    }

    func replies(postID: String) async throws -> [Post] {
        let json = try await request(.detail, variables: ["focalTweetId": postID, "referrer": "tweet", "withFocalTweet": true])
        return try XResponseParser.timeline(json.at("data.threaded_conversation_with_injections_v2"))
            .entries.map(\.post).filter { $0.replyToID == postID }
    }

    func searchPosts(_ query: String) async throws -> [Post] {
        try XResponseParser.timeline(await search(query, product: "Latest")).entries.map(\.post)
    }

    func searchUsers(_ query: String) async throws -> [User] {
        XResponseParser.users(in: try await search(query, product: "People"))
    }

    private func search(_ query: String, product: String) async throws -> JSONValue {
        let json = try await request(.search, variables: ["rawQuery": query, "count": 20, "product": product, "querySource": "typed_query", "withMediaGridTweet": false])
        let timeline = json.at("data.search_by_raw_query.search_timeline.timeline")
        guard !timeline["instructions"].isNull else { throw XAPIError.responseChanged }
        return timeline
    }

    func makeRequest(_ operation: XOperation, variables: [String: Any]) throws -> URLRequest {
        var variables = variables
        if operation.modern {
            variables["__relay_internal__pv__xclientsfeaturesappviewerisloggedinrelayprovider"] = true
            variables["__relay_internal__pv__xclientsfeaturestranslationnoteautotranslationenabledrelayprovider"] = false
        }
        let credentials = credentials()
        guard credentials.isComplete else { throw XAPIError.missingSession }
        var components = URLComponents(string: "\(operation.baseURL)/\(operation.path)")
        if !operation.modern {
            components?.queryItems = [
                URLQueryItem(name: "variables", value: String(decoding: try JSONSerialization.data(withJSONObject: variables), as: UTF8.self)),
                URLQueryItem(name: "features", value: String(decoding: try JSONSerialization.data(withJSONObject: XLegacyFeatures.values), as: UTF8.self))
            ]
        }
        guard let url = components?.url else { throw XAPIError.responseChanged }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.allHTTPHeaderFields = credentials.headers(modern: operation.modern)
        request.httpMethod = operation.modern ? "POST" : "GET"
        if operation.modern {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["queryId": String(operation.path.split(separator: "/")[0]), "variables": variables])
        }
        return request
    }

    private func request(_ operation: XOperation, variables: [String: Any]) async throws -> JSONValue {
        let (data, response) = try await session.data(for: makeRequest(operation, variables: variables))
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse else { throw XAPIError.responseChanged }
        let json = try? JSONDecoder().decode(JSONValue.self, from: data)
        try Self.validate(response, json: json)
        guard let json, !json["data"].isNull else { throw XAPIError.responseChanged }
        return json
    }

    nonisolated static func validate(_ response: HTTPURLResponse, json: JSONValue?) throws {
        let codes = json?["errors"].array.compactMap { $0["code"].int } ?? []
        if [401, 403].contains(response.statusCode) || codes.contains(where: { [32, 89, 215, 326, 353].contains($0) }) { throw XAPIError.sessionExpired }
        if response.statusCode == 429 || codes.contains(88) {
            let reset = response.value(forHTTPHeaderField: "x-rate-limit-reset").flatMap(Double.init).map { Date(timeIntervalSince1970: $0) }
                ?? response.value(forHTTPHeaderField: "retry-after").flatMap(Double.init).map { Date.now.addingTimeInterval($0) }
            throw XAPIError.rateLimited(reset)
        }
        if [404, 410].contains(response.statusCode) { throw XAPIError.operationUnavailable }
        guard (200..<300).contains(response.statusCode) else { throw XAPIError.server(response.statusCode) }
    }
}
