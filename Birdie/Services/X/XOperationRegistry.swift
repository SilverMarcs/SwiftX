import Foundation

/// Keeps public operation metadata only. Request cookies, tokens, and user variables are discarded.
@MainActor
final class XOperationRegistry {
    static let shared = XOperationRegistry()

    private var operations: [String: XOperation] = [:]
    private var observedNames = Set<String>()
    private var successfulRefreshes: [String: Date] = [:]
    private var failedRefreshes: [String: Date] = [:]
    private var refreshTask: Task<Set<String>, Never>?
    private var requestedNames = Set<String>()
    private var deadline = Date.distantPast
    private var lastFailedRefresh: Date?

    private init() {
        for definition in XOperationCatalog.definitions {
            if let id = definition.queryID { install(definition.operation(queryID: id)) }
        }
    }

    func operation(named name: String) -> XOperation? { operations[XOperationCatalog.canonicalName(name)] }

    /// A rejected route must be rediscovered on the next explicit request, without replaying a write.
    func invalidateMetadata(for name: String) {
        let canonical = XOperationCatalog.canonicalName(name)
        successfulRefreshes[canonical] = nil
        observedNames.remove(canonical)
    }

    /// An observed signed-in web request takes precedence over public fallback metadata.
    func observe(url: String, body: [String: Any], method: String? = nil) {
        guard let endpoint = URL(string: url), Self.isXAPI(endpoint),
              let graphqlIndex = endpoint.pathComponents.firstIndex(of: "graphql"),
              endpoint.pathComponents.count > graphqlIndex + 2 else { return }
        let queryID = endpoint.pathComponents[graphqlIndex + 1]
        let name = endpoint.pathComponents[graphqlIndex + 2]
        guard let definition = XOperationCatalog.definition(named: name), Self.isValidID(queryID) else { return }
        let query = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)?.queryItems ?? []
        func object(_ key: String) -> [String: Any]? {
            if let value = body[key] as? [String: Any] { return value }
            let encoded = body[key] as? String ?? query.first(where: { $0.name == key })?.value
            guard let encoded, let data = encoded.data(using: .utf8) else { return nil }
            return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        }
        let variables = object("variables") ?? [:]
        let providers = variables.filter { $0.key.hasPrefix("__relay_internal__pv__") }.compactMapValues { $0 as? Bool }
        let features = object("features")
        let isRelay = !providers.isEmpty || (features == nil && definition.isRelay)
        var cleanEndpoint = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        cleanEndpoint?.query = nil
        cleanEndpoint?.fragment = nil
        guard let cleanURL = cleanEndpoint?.url,
              method == nil || method == definition.method else { return }
        install(definition.operation(queryID: queryID, isRelay: isRelay, endpoint: cleanURL,
                                     features: features?.compactMapValues { $0 as? Bool } ?? [:],
                                     relayVariables: providers.isEmpty ? nil : providers,
                                     fieldToggles: object("fieldToggles")?.compactMapValues { $0 as? Bool }))
        observedNames.insert(definition.canonicalName)
        successfulRefreshes[definition.canonicalName] = .now
    }

    /// Writes discover metadata before sending once; discovery never performs the write itself.
    func refresh(for name: String, force: Bool = false) async {
        guard !Task.isCancelled, let definition = XOperationCatalog.definition(named: name) else { return }
        let key = definition.canonicalName
        let currentTime = Date.now
        guard force || (successfulRefreshes[key].map({ currentTime.timeIntervalSince($0) >= 3_600 }) ?? true) else { return }
        guard failedRefreshes[key].map({ currentTime.timeIntervalSince($0) >= 60 }) ?? true,
              lastFailedRefresh.map({ currentTime.timeIntervalSince($0) >= 60 }) ?? true else { return }
        // An explicit failed-read refresh may replace the metadata captured during login.
        if force { observedNames.remove(key) }
        requestedNames.insert(key)
        if let task = refreshTask {
            _ = await task.value
            return
        }
        deadline = currentTime.addingTimeInterval(4)
        let task = Task { @MainActor [self] in
            let found = await discover()
            let finishedAt = Date.now
            for requested in requestedNames {
                if found.contains(requested) {
                    successfulRefreshes[requested] = finishedAt
                    failedRefreshes[requested] = nil
                } else {
                    failedRefreshes[requested] = finishedAt
                }
            }
            for discovered in found {
                successfulRefreshes[discovered] = finishedAt
                failedRefreshes[discovered] = nil
            }
            if found.isEmpty { lastFailedRefresh = finishedAt }
            refreshTask = nil
            requestedNames = []
            return found
        }
        refreshTask = task
        _ = await task.value
    }

    /// Fetches only public bootstrap and relevant route scripts, within a total deadline and asset count.
    private func discover() async -> Set<String> {
        guard let root = URL(string: "https://x.com"), let html = await fetchWithinDeadline(root) else { return [] }
        var pending = Self.assetURLs(in: html, relativeTo: root, requestedNames: requestedNames)
        var visited = Set<URL>()
        var found = Set<String>()
        while !pending.isEmpty && visited.count < 8 && Date.now < deadline {
            guard !Task.isCancelled else { break }
            let prefixes = XOperationCatalog.assetPrefixes(for: requestedNames)
            pending.sort { Self.priority($0, prefixes: prefixes) < Self.priority($1, prefixes: prefixes) }
            let url = pending.removeFirst()
            guard visited.insert(url).inserted, let script = await fetchWithinDeadline(url) else { continue }
            for operation in Self.operations(in: script) {
                let canonical = XOperationCatalog.canonicalName(operation.name)
                found.insert(canonical)
                if !observedNames.contains(canonical) { install(operation) }
            }
            if requestedNames.isSubset(of: found) { break }
            for asset in Self.assetURLs(in: script, relativeTo: url, requestedNames: requestedNames)
                where !visited.contains(asset) && !pending.contains(asset) {
                pending.append(asset)
            }
        }
        return found
    }

    private func fetchWithinDeadline(_ url: URL) async -> String? {
        guard !Task.isCancelled, url.scheme == "https", ["x.com", "abs.twimg.com"].contains(url.host()) else { return nil }
        let remaining = deadline.timeIntervalSinceNow
        guard remaining > 0 else { return nil }
        return await Self.fetch(url, timeout: min(2, remaining))
    }

    static func operations(in script: String) -> [XOperation] {
        var result: [XOperation] = []
        let relayPattern = #"params:\s*\{id:\s*[`\"]([A-Za-z0-9_-]+)[`\"],metadata:\s*\{[^}]*\},name:\s*[`\"]([A-Za-z0-9_]+)[`\"]"#
        for groups in matches(relayPattern, in: script) {
            guard let definition = XOperationCatalog.definition(named: groups[1]) else { continue }
            result.append(definition.operation(queryID: groups[0], isRelay: true))
        }
        let legacyPattern = #"queryId:\s*[`\"]([A-Za-z0-9_-]+)[`\"],operationName:\s*[`\"]([A-Za-z0-9_]+)[`\"]"#
        for groups in matches(legacyPattern, in: script) {
            guard let definition = XOperationCatalog.definition(named: groups[1]) else { continue }
            result.append(definition.operation(queryID: groups[0], isRelay: false))
        }
        return result
    }

    private func install(_ operation: XOperation) {
        operations[XOperationCatalog.canonicalName(operation.name)] = operation
    }

    private static func fetch(_ url: URL, timeout: TimeInterval) async -> String? {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        // Deliberately carries no cookies or cached responses from any signed-in session.
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration)
        defer { session.finishTasksAndInvalidate() }
        guard let (data, response) = try? await session.data(for: request),
              let response = response as? HTTPURLResponse, response.statusCode == 200 else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func assetURLs(in text: String, relativeTo base: URL, requestedNames: Set<String>) -> [URL] {
        let pattern = #"[\"'`](https://abs\.twimg\.com/[^\"'`\s]+\.js|\.?\.?/[^\"'`\s]+\.js|assets/[^\"'`\s]+\.js)[\"'`]"#
        let prefixes = XOperationCatalog.assetPrefixes(for: requestedNames)
        var seen = Set<URL>()
        return matches(pattern, in: text).compactMap { groups in
            // Vite dependency-map paths start at the bundle root; ./ imports start at the module.
            let path = groups[0]
            let directory = base.deletingLastPathComponent()
            let reference = path.hasPrefix("assets/") && directory.lastPathComponent == "assets"
                ? directory.deletingLastPathComponent() : base
            guard let url = URL(string: path, relativeTo: reference)?.absoluteURL,
                  url.scheme == "https", url.host() == "abs.twimg.com",
                  prefixes.contains(where: url.lastPathComponent.hasPrefix), seen.insert(url).inserted else { return nil }
            return url
        }.sorted { priority($0, prefixes: prefixes) < priority($1, prefixes: prefixes) }
    }

    private static func priority(_ url: URL, prefixes: [String]) -> Int {
        prefixes.firstIndex(where: url.lastPathComponent.hasPrefix) ?? prefixes.count
    }

    private static func matches(_ pattern: String, in source: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: source, range: NSRange(source.startIndex..., in: source)).map { match in
            (1..<match.numberOfRanges).compactMap { Range(match.range(at: $0), in: source).map { String(source[$0]) } }
        }
    }

    private static func isXAPI(_ url: URL) -> Bool {
        url.scheme == "https" && ["x.com", "api.x.com", "twitter.com", "api.twitter.com"].contains(url.host())
    }

    private static func isValidID(_ id: String) -> Bool {
        !id.isEmpty && id.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_" || $0 == "-") }
    }
}
