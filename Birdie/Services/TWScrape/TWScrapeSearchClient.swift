import Foundation

struct TWScrapeSearchClient {
    private let session: URLSession
    private let accountProvider: () -> TWScrapeAccount

    init(session: URLSession = .shared, accountProvider: @escaping () -> TWScrapeAccount = { .current }) {
        self.session = session
        self.accountProvider = accountProvider
    }

    func search(query: String, product: String, limit: Int) async throws -> [TWScrapeSearchResponse] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, limit > 0 else { return [] }

        let account = accountProvider()
        guard !account.cookieHeader.isEmpty, !account.authorizationBearer.isEmpty,
              let csrf = account.csrfToken, !csrf.isEmpty else {
            throw TWScrapeSearchError.missingCredentials
        }

        var pages: [TWScrapeSearchResponse] = []
        var cursor: String?
        var seenCursors = Set<String>()

        for _ in 0..<min(12, (limit - 1) / 20 + 1) {
            try Task.checkCancellation()
            // Operation and variables come from X's current web search bundle.
            var components = URLComponents(string: "https://api.x.com/graphql/mSbI6UIYLPd7b9qkaJ6SAA/SearchByRawQuery")
            var variables: [String: Any] = [
                "rawQuery": query, "product": product, "querySource": "typed_query",
                "count": 20, "withMediaGridTweet": false,
                "__relay_internal__pv__xclientsfeaturesappviewerisloggedinrelayprovider": true,
                "__relay_internal__pv__xclientsfeaturestranslationnoteautotranslationenabledrelayprovider": false
            ]
            if let cursor { variables["cursor"] = cursor }
            let data = try JSONSerialization.data(withJSONObject: variables)
            components?.queryItems = [URLQueryItem(name: "variables", value: String(decoding: data, as: UTF8.self))]
            guard let url = components?.url else { throw NetworkError.invalidURL }

            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = account.authHeaders()
            request.setValue("Tia", forHTTPHeaderField: "x-twitter-auth-type")
            request.setValue(nil, forHTTPHeaderField: "x-guest-token")
            let (body, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else { throw TWScrapeSearchError.invalidResponse }
            guard response.statusCode == 200 else { throw TWScrapeSearchError.httpStatus(response.statusCode) }
            guard let json = try JSONSerialization.jsonObject(with: body) as? [String: Any] else {
                throw TWScrapeSearchError.invalidResponse
            }
            let page = try TWScrapeSearchResponse(json: json)
            pages.append(page)
            guard let next = page.nextCursor, seenCursors.insert(next).inserted else { break }
            cursor = next
        }
        return pages
    }
}
