import Foundation

/// Keeps public operation metadata only. Request cookies, tokens, and user variables are discarded.
@MainActor
final class XOperationRegistry {
    static let shared = XOperationRegistry()

    private var operations: [String: XOperation] = [:]
    private var observedNames = Set<String>()
    private var refreshedAt: Date?

    init() {
        let relay = Self.relayDefaults
        let seeds = [
            XOperation(name: "HomeLatestTimelineQuery", queryID: "Lk_3-p7nX68Uq1VFYo0m0g", relayVariables: relay, isRelay: true),
            XOperation(name: "HomeTimelineQuery", queryID: "msrNpQ16xpmF5Um0O4Y_Zg", relayVariables: relay, isRelay: true),
            XOperation(name: "UserByScreenName", queryID: "yvm61GcJCIpqEwe_3RBccw", relayVariables: relay, isRelay: true),
            XOperation(name: "UserOriginalsTimeline", queryID: "U9W6pwnA7XeTBja_ql4lbw", relayVariables: relay, isRelay: true),
            XOperation(name: "TweetDetail", queryID: "mw1YqNf95jXRYKKJMGKzgw", relayVariables: relay, isRelay: true),
            XOperation(name: "SearchByRawQuery", queryID: "mSbI6UIYLPd7b9qkaJ6SAA", relayVariables: relay, isRelay: true),
            XOperation(name: "UserByRestId", queryID: "xvmVfRLmnr1alc5f2dib0Q"),
            XOperation(name: "viewerQuery", queryID: "fJ_6rPf08JjvZdq-D2jACg", relayVariables: relay, isRelay: true),
            XOperation(name: "followUserMutation", queryID: "m5VXpPA-MH4DH7epCa7hCg", method: "POST", isRelay: true),
            XOperation(name: "unfollowUserMutation", queryID: "RjGnpAQuMmcqXSjoCR7t6w", method: "POST", isRelay: true)
        ]
        for operation in seeds { install(operation) }
    }

    func operation(named name: String) -> XOperation? { operations[Self.canonicalName(name)] }

    /// An observed signed-in web request takes precedence over public fallback metadata.
    func observe(url: String, body: [String: Any], method: String? = nil) {
        guard let endpoint = URL(string: url), Self.isXAPI(endpoint),
              let graphqlIndex = endpoint.pathComponents.firstIndex(of: "graphql"),
              endpoint.pathComponents.count > graphqlIndex + 2 else { return }
        let queryID = endpoint.pathComponents[graphqlIndex + 1]
        let name = endpoint.pathComponents[graphqlIndex + 2]
        guard Self.allowedNames.contains(name), Self.isValidID(queryID) else { return }
        let query = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)?.queryItems ?? []
        func object(_ key: String) -> [String: Any] {
            if let value = body[key] as? [String: Any] { return value }
            let encoded = body[key] as? String ?? query.first(where: { $0.name == key })?.value
            guard let encoded, let data = encoded.data(using: .utf8),
                  let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
            return object
        }
        let variables = object("variables")
        let relayVariables = variables.filter { $0.key.hasPrefix("__relay_internal__pv__") }.compactMapValues { $0 as? Bool }
        let isRelay = !relayVariables.isEmpty || name == "HomeLatestTimelineQuery" || name == "HomeTimelineQuery"
            || name == "UserOriginalsTimeline" || name.hasSuffix("Mutation") || name == "viewerQuery"
        var cleanEndpoint = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        cleanEndpoint?.query = nil
        cleanEndpoint?.fragment = nil
        guard let cleanURL = cleanEndpoint?.url else { return }
        let operation = XOperation(name: name, queryID: queryID, method: method ?? (body.isEmpty ? "GET" : "POST"),
                                   features: object("features").compactMapValues { $0 as? Bool },
                                   relayVariables: relayVariables, endpoint: cleanURL, isRelay: isRelay)
        install(operation)
        observedNames.insert(Self.canonicalName(name))
    }

    /// Best-effort discovery from X's public JavaScript. A failed refresh retains known metadata.
    func refresh() async {
        guard refreshedAt.map({ Date().timeIntervalSince($0) > 3_600 }) ?? true else { return }
        guard let root = URL(string: "https://x.com"), let html = await fetch(root) else { return }
        var pending = Self.assetURLs(in: html, relativeTo: root)
        var visited = Set<URL>()
        // Only follow boot scripts and the few routes Birdie uses, with a strict fetch budget.
        while !pending.isEmpty && visited.count < 24 {
            if Task.isCancelled { return }
            let url = pending.removeFirst()
            guard visited.insert(url).inserted, let script = await fetch(url) else { continue }
            for operation in Self.operations(in: script) where !observedNames.contains(Self.canonicalName(operation.name)) {
                install(operation)
            }
            for asset in Self.assetURLs(in: script, relativeTo: url) where !visited.contains(asset) && !pending.contains(asset) {
                pending.append(asset)
            }
        }
        refreshedAt = Date()
    }

    static func operations(in script: String) -> [XOperation] {
        var result: [XOperation] = []
        // Relay compiled artifacts embed stable operation metadata in params objects.
        let relayPattern = #"params:\s*\{id:\s*[`\"]([A-Za-z0-9_-]+)[`\"],metadata:\s*\{[^}]*\},name:\s*[`\"]([A-Za-z0-9_]+)[`\"]"#
        for groups in matches(relayPattern, in: script) where allowedNames.contains(groups[1]) {
            result.append(XOperation(name: groups[1], queryID: groups[0],
                                     method: groups[1].hasSuffix("Mutation") ? "POST" : "GET",
                                     relayVariables: groups[1].hasSuffix("Mutation") ? [:] : relayDefaults, isRelay: true))
        }
        // Legacy webpack artifacts expose queryId/operationName metadata instead.
        let legacyPattern = #"queryId:\s*[`\"]([A-Za-z0-9_-]+)[`\"],operationName:\s*[`\"]([A-Za-z0-9_]+)[`\"]"#
        for groups in matches(legacyPattern, in: script) where allowedNames.contains(groups[1]) {
            result.append(XOperation(name: groups[1], queryID: groups[0], method: groups[1] == "HomeLatestTimeline" ? "POST" : "GET"))
        }
        return result
    }

    private func install(_ operation: XOperation) { operations[Self.canonicalName(operation.name)] = operation }

    private func fetch(_ url: URL) async -> String? {
        guard url.scheme == "https", ["x.com", "abs.twimg.com"].contains(url.host()) else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        // This session deliberately carries no cookies from the embedded signed-in session.
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        let session = URLSession(configuration: configuration)
        defer { session.finishTasksAndInvalidate() }
        guard let (data, response) = try? await session.data(for: request),
              let response = response as? HTTPURLResponse, response.statusCode == 200 else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func assetURLs(in text: String, relativeTo base: URL) -> [URL] {
        let pattern = #"[\"'`](https://abs\.twimg\.com/[^\"'`\s]+\.js|\.?\.?/[^\"'`\s]+\.js|assets/[^\"'`\s]+\.js)[\"'`]"#
        return matches(pattern, in: text).compactMap { groups in
            guard let url = URL(string: groups[0], relativeTo: base)?.absoluteURL,
                  url.host() == "abs.twimg.com" else { return nil }
            let name = url.lastPathComponent
            let prefixes = ["entry-client", "startup-", "home-", "user-posts-", "user-profile-", "_profile-", "conversation-", "UserByScreenName.", "search-results", "search-", "follow-user-", "unfollow-user-"]
            return prefixes.contains(where: name.hasPrefix) ? url : nil
        }.sorted { priority($0) < priority($1) }
    }

    private static func matches(_ pattern: String, in source: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: source, range: NSRange(source.startIndex..., in: source)).map { match in
            (1..<match.numberOfRanges).compactMap { Range(match.range(at: $0), in: source).map { String(source[$0]) } }
        }
    }

    private static func canonicalName(_ name: String) -> String {
        switch name {
        case "HomeLatestTimelineQuery": "HomeLatestTimeline"
        case "HomeTimelineQuery": "HomeTimeline"
        case "UserOriginalsTimeline": "UserTweets"
        default: name
        }
    }

    private static func priority(_ url: URL) -> Int {
        let prefixes = ["entry-client", "startup-dynamic", "startup-", "UserByScreenName.", "home-", "user-posts-", "follow-user-", "unfollow-user-", "user-profile-", "_profile-", "conversation-", "search-"]
        return prefixes.firstIndex(where: url.lastPathComponent.hasPrefix) ?? prefixes.count
    }

    private static func isXAPI(_ url: URL) -> Bool {
        url.scheme == "https" && ["x.com", "api.x.com", "twitter.com", "api.twitter.com"].contains(url.host())
    }

    private static func isValidID(_ id: String) -> Bool {
        !id.isEmpty && id.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_" || $0 == "-") }
    }

    private static let relayDefaults = [
        "__relay_internal__pv__xclientsfeaturesappviewerisloggedinrelayprovider": true,
        "__relay_internal__pv__xclientsfeaturestranslationnoteautotranslationenabledrelayprovider": false
    ]

    private static let allowedNames: Set<String> = [
        "HomeLatestTimeline", "HomeLatestTimelineQuery", "HomeTimeline", "HomeTimelineQuery", "UserByRestId", "UserByScreenName",
        "UserTweets", "UserOriginalsTimeline", "TweetDetail", "SearchByRawQuery", "viewerQuery",
        "followUserMutation", "unfollowUserMutation"
    ]
}
