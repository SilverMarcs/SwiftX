import Foundation

/// A web session belongs to one account. It is stored only in the device Keychain.
struct XCredentials: Codable, Equatable {
    let authToken: String
    let csrfToken: String
    let bearer: String
    let userAgent: String

    var isValid: Bool {
        !authToken.isEmpty && !csrfToken.isEmpty && !bearer.isEmpty && !userAgent.isEmpty
    }

    var headers: [String: String] {
        [
            "accept": "*/*",
            "content-type": "application/json",
            "authorization": bearer,
            "cookie": "auth_token=\(authToken); ct0=\(csrfToken)",
            "x-csrf-token": csrfToken,
            "user-agent": userAgent,
            "x-twitter-active-user": "yes",
            "x-twitter-auth-type": "OAuth2Session",
            "x-twitter-client-language": "en",
            "origin": "https://x.com",
            "referer": "https://x.com/"
        ]
    }
}
