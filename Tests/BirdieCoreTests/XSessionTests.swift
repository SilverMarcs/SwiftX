import Foundation
import Testing
@testable import BirdieCore

struct XSessionTests {
    @Test func requiresAuthenticatedCookiesWithoutAnyListOrGuestToken() {
        let session = XSession(cookie: "Cookie: auth_token=example; ct0=csrf==; twid=account", authorization: " example ", userAgent: "")
        #expect(session.isComplete)
        #expect(session.cookieValue("ct0") == "csrf==")
        #expect(session.normalizedAuthorization == "Bearer example")
        #expect(session.headers(modern: true)["x-twitter-auth-type"] == "Tia")
        #expect(session.headers(modern: true)["x-guest-token"] == nil)
        #expect(!XSession(cookie: "ct0=csrf", authorization: "example", userAgent: "").isComplete)
    }

    @Test func accountKeyDoesNotContainCredentialsAndSurvivesTokenRotation() {
        let a = XSession(cookie: "auth_token=one; ct0=a; twid=account", authorization: "example", userAgent: "")
        let b = XSession(cookie: "auth_token=two; ct0=b; twid=account", authorization: "example", userAgent: "")
        #expect(a.accountKey == b.accountKey)
        #expect(a.accountKey.count == 64)
    }

    @Test @MainActor func modernRequestUsesFrontendPOSTAndNoLegacySwitches() throws {
        let client = XClient(credentials: { XSession(cookie: "auth_token=example; ct0=csrf", authorization: "example", userAgent: "") })
        let request = try client.makeRequest(.home, variables: ["count": 20, "seenTweetIds": ["post"]])
        #expect(request.url?.host() == "api.x.com")
        #expect(request.httpMethod == "POST")
        let body = try JSONDecoder().decode(JSONValue.self, from: #require(request.httpBody))
        #expect(body["features"].isNull)
        #expect(body.at("variables.seenTweetIds").array.first?.string == "post")
    }

    @Test func detectsAuthenticationErrorsInsideHTTP200AndRateLimits() throws {
        let url = try #require(URL(string: "https://api.x.com/graphql"))
        let ok = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
        #expect(throws: XAPIError.sessionExpired) { try XClient.validate(ok, json: Fixtures.json(["errors": [["code": 89]]])) }
        let limited = try #require(HTTPURLResponse(url: url, statusCode: 429, httpVersion: nil, headerFields: ["x-rate-limit-reset": "1700000000"]))
        #expect(throws: XAPIError.rateLimited(Date(timeIntervalSince1970: 1_700_000_000))) { try XClient.validate(limited, json: nil) }
    }

    @Test @MainActor func boundedSeenHistoryIsIsolatedByAccountAndPersistsPendingIDs() throws {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        let seen = SeenPostStore(defaults: defaults, limit: 2)
        seen.configure(accountKey: "a")
        for id in ["one", "one", "two", "three"] { seen.markVisible(id) }
        #expect(seen.pending == ["two", "three"])
        seen.configure(accountKey: "b")
        #expect(seen.pending.isEmpty)
        seen.markVisible("other")
        seen.configure(accountKey: "a")
        #expect(seen.pending == ["two", "three"])
        seen.acknowledge(["two"])
        let reloaded = SeenPostStore(defaults: defaults, limit: 2)
        reloaded.configure(accountKey: "a")
        #expect(reloaded.pending == ["three"])
    }
}
