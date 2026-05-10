import Foundation

struct TWScrapeAccount {
    let cookieHeader: String
    let authorizationBearer: String
    let userAgent: String
    let guestToken: String
    let csrfToken: String?

    static var current: TWScrapeAccount {
        let store = XAuthStore.shared
        return TWScrapeAccount(
            cookieHeader: store.normalizedCookieHeader(),
            authorizationBearer: store.authorizationBearer,
            userAgent: store.userAgent,
            guestToken: store.guestToken,
            csrfToken: store.extractCookie(named: "ct0")
        )
    }

    func authHeaders() -> [String: String] {
        var headers: [String: String] = [
            "accept": "*/*",
            "accept-encoding": "gzip, deflate, br",
            "accept-language": "en-US,en;q=0.9",
            "user-agent": userAgent,
            "content-type": "application/json",
            "x-twitter-active-user": "yes",
            "x-twitter-client-language": "en",
            "x-twitter-auth-type": "OAuth2Session",
            "cookie": cookieHeader
        ]
        if !authorizationBearer.isEmpty {
            headers["authorization"] = authorizationBearer
        }
        if !guestToken.isEmpty {
            headers["x-guest-token"] = guestToken
        }
        if let csrfToken {
            headers["x-csrf-token"] = csrfToken
        }
        return headers
    }
}
