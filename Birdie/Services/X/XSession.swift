import CryptoKit
import Foundation

nonisolated struct XSession: Codable, Sendable {
    var cookie: String
    var authorization: String
    var userAgent: String

    var normalizedCookie: String {
        let value = cookie.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.lowercased().hasPrefix("cookie:") ? String(value.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines) : value
    }

    var normalizedAuthorization: String {
        let value = authorization.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty || value.lowercased().hasPrefix("bearer ") ? value : "Bearer \(value)"
    }

    var isComplete: Bool {
        cookieValue("auth_token")?.isEmpty == false && cookieValue("ct0")?.isEmpty == false && !normalizedAuthorization.isEmpty
    }

    /// Partition non-secret seen-post history without storing cookie values in preferences.
    var accountKey: String {
        let identity = cookieValue("twid") ?? cookieValue("auth_token") ?? ""
        return SHA256.hash(data: Data(identity.utf8)).map {
            let hex = String($0, radix: 16)
            return hex.count == 1 ? "0\(hex)" : hex
        }.joined()
    }

    func cookieValue(_ name: String) -> String? {
        for part in normalizedCookie.split(separator: ";") {
            let pair = part.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            if pair.count == 2, pair[0].trimmingCharacters(in: .whitespaces) == name {
                return pair[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    func headers(modern: Bool) -> [String: String] {
        [
            "accept": "application/json",
            "content-type": "application/json",
            "cookie": normalizedCookie,
            "authorization": normalizedAuthorization,
            "x-csrf-token": cookieValue("ct0") ?? "",
            "x-twitter-auth-type": modern ? "Tia" : "OAuth2Session",
            "x-twitter-active-user": "yes",
            "x-twitter-client-language": "en",
            "user-agent": userAgent.isEmpty ? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 Version/26.0 Safari/605.1.15" : userAgent,
            "referer": "https://x.com/home",
            "origin": "https://x.com"
        ]
    }
}
