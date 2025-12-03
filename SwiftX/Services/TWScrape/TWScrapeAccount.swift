import Foundation

struct TWScrapeAccount {
    let username: String
    let headers: [String: String]
    let cookies: [String: String]
    let userAgent: String

    static let defaultActive: TWScrapeAccount = TWScrapeAccount(
        username: "REDACTED",
        headers: [
            "accept": "*/*",
            "accept-encoding": "gzip, deflate",
            "connection": "keep-alive",
            "user-agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
            "content-type": "application/json",
            "authorization": "Bearer REDACTED",
            "x-twitter-active-user": "yes",
            "x-twitter-client-language": "en",
            "x-guest-token": "REDACTED",
            "x-csrf-token": "REDACTED",
            "x-twitter-auth-type": "OAuth2Session"
        ],
        cookies: [
            "guest_id_marketing": "v1%3AREDACTED",
            "guest_id_ads": "v1%3AREDACTED",
            "personalization_id": "\"REDACTED==\"",
            "guest_id": "v1%3AREDACTED",
            "__cf_bm": "REDACTED",
            "kdt": "REDACTED",
            "twid": "\"u=REDACTED\"",
            "ct0": "REDACTED",
            "auth_token": "REDACTED",
            "att": "REDACTED"
        ],
        userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1"
    )

    func cookieHeader() -> String {
        cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
    }

    func authHeaders() -> [String: String] {
        var result: [String: String] = [
            "accept": "*/*",
            "accept-encoding": "gzip, deflate, br",
            "accept-language": "en-US,en;q=0.9",
            "user-agent": userAgent,
            "content-type": "application/json"
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
}
