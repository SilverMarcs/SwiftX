import Foundation

/// Builds X's web GraphQL envelope without sharing a browser cookie store.
enum XGraphQLRequest {
    static func make(operation: XOperation, variables: [String: Any], credentials: XCredentials) throws -> URLRequest {
        var variables = variables
        for (key, value) in operation.relayVariables { variables[key] = value }
        var payload: [String: Any] = ["variables": variables]
        if !operation.isRelay {
            if !operation.features.isEmpty { payload["features"] = operation.features }
            if !operation.fieldToggles.isEmpty { payload["fieldToggles"] = operation.fieldToggles }
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
            // The web client repeats the operation ID here, even though it is in the URL.
            payload["queryId"] = operation.queryID
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        }
        return request
    }
}
