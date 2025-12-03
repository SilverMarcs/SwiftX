import Foundation

struct TWScrapeAccount {
    let username: String
    let headers: [String: String]
    let cookies: [String: String]
    let userAgent: String
    let active: Bool

    static var defaultActive: TWScrapeAccount {
        stubs.first { $0.active } ?? stubs[0]
    }

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

// Stubs copied from twscrape-serverless/accounts.json
extension TWScrapeAccount {
    static let stubs: [TWScrapeAccount] = [
        TWScrapeAccount(
            username: "ZabirRaihan6",
            headers: [
                "accept": "*/*",
                "accept-encoding": "gzip, deflate",
                "connection": "keep-alive",
                "user-agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
                "content-type": "application/json",
                "authorization": "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA",
                "x-twitter-active-user": "yes",
                "x-twitter-client-language": "en",
                "x-guest-token": "1944317346782539966",
                "x-csrf-token": "691c191ecb6e6c2ccc9db7229633768b9ae5a2ae66e32c1a29eab0fc66359188d4a25f769e86361bb47fd23bc4e69898ed6d2205f7651471362ac596fa10220704fee535b573aa63bdb3819b108e53dc",
                "x-twitter-auth-type": "OAuth2Session"
            ],
            cookies: [
                "guest_id_marketing": "v1%3A175239635379340338",
                "guest_id_ads": "v1%3A175239635379340338",
                "personalization_id": "\"v1_lOnNL9itGt3j8EBvdRICww==\"",
                "guest_id": "v1%3A175239635379340338",
                "__cf_bm": "cjwW6uWkw24xlsIQAKG49wnELTn4z.oHIgxGDzd0Nos-1752396353-1.0.1.1-tiaNrbvdMgavE1MJ6KOBjytCG7YcSr4upfcqMSOb5tFMJsVhWeyPdbjxreXX65rO8cM37Jz7BwDk11Q.eO47PJ_cd18TCkTZFtlNY4MEvXA",
                "kdt": "Ae8cgmkuzMpFoWxDpYZ8bPu5tSjYdgapQ9rwPyky",
                "twid": "\"u=1920525919464329216\"",
                "ct0": "691c191ecb6e6c2ccc9db7229633768b9ae5a2ae66e32c1a29eab0fc66359188d4a25f769e86361bb47fd23bc4e69898ed6d2205f7651471362ac596fa10220704fee535b573aa63bdb3819b108e53dc",
                "auth_token": "6180de3ff8cb16b73396f797bf6a497c23a44433",
                "att": "1-UJjl7HjBjvW551cBvutDzrZsCNyKh9zCCWb0RLCc"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
            active: true
        ),
        TWScrapeAccount(
            username: "zabir.raihan8@gmail.com",
            headers: [:],
            cookies: [
                "auth_token": "d6e6e2131bf74b6ced768de7217186c910a77d26",
                "ct0": "d159fa38cd9ca7c075b422b6657452346d4881356ad0cbf4fd4784a4e02ecc193abe9e80d0e9df8fbf1dbd7880401b674a5a0987977eda69825ca05d32b96c42967a7a900d767d3843a3274a9242c154"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Mobile/15E148 Safari/604.1",
            active: true
        ),
        TWScrapeAccount(
            username: "Davidd609198688",
            headers: [:],
            cookies: [
                "auth_token": "962d2da2540ea664e3bba85d9b5d0833d097aac1",
                "ct0": "4e897f6321f387edf99bc2e1fc7e3ccd0a15337dafb8aaca44224c2ea60e6b4af85e8fa61abca992c24204748e9edbe744671aec566b5b1e84728e90d56e0419099dbdc796f922e2b0d8cf4fe6331bea"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Mobile/15E148 Safari/604.1",
            active: true
        ),
        TWScrapeAccount(
            username: "RaihanZabi14335",
            headers: [:],
            cookies: [
                "auth_token": "d6e6e2131bf74b6ced768de7217186c910a77d26",
                "ct0": "d159fa38cd9ca7c075b422b6657452346d4881356ad0cbf4fd4784a4e02ecc193abe9e80d0e9df8fbf1dbd7880401b674a5a0987977eda69825ca05d32b96c42967a7a900d767d3843a3274a9242c154"
            ],
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1",
            active: true
        )
    ]
}
