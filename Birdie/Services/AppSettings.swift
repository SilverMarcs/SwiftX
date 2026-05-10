import Foundation
import Observation

@Observable
final class XAuthStore {
    static let shared = XAuthStore()

    var listId: String {
        didSet { UserDefaults.standard.set(listId, forKey: Keys.listId) }
    }

    var userAgent: String {
        didSet { UserDefaults.standard.set(userAgent, forKey: Keys.userAgent) }
    }

    var cookieHeader: String {
        didSet { KeychainManager.shared.save(key: Keys.cookieHeader, data: cookieHeader) }
    }

    var authorizationBearer: String {
        didSet { KeychainManager.shared.save(key: Keys.authorizationBearer, data: authorizationBearer) }
    }

    var guestToken: String {
        didSet { KeychainManager.shared.save(key: Keys.guestToken, data: guestToken) }
    }

    private init() {
        listId = UserDefaults.standard.string(forKey: Keys.listId) ?? ""
        userAgent = UserDefaults.standard.string(forKey: Keys.userAgent) ?? ""
        cookieHeader = KeychainManager.shared.load(key: Keys.cookieHeader) ?? ""
        authorizationBearer = KeychainManager.shared.load(key: Keys.authorizationBearer) ?? ""
        guestToken = KeychainManager.shared.load(key: Keys.guestToken) ?? ""
    }

    var isAuthenticated: Bool {
        !normalizedCookieHeader().isEmpty && !listId.isEmpty
    }

    func normalizedCookieHeader() -> String {
        let trimmed = cookieHeader.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.lowercased().hasPrefix("cookie:") {
            return trimmed.dropFirst("cookie:".count).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }

    func extractCookie(named name: String) -> String? {
        let header = normalizedCookieHeader()
        for part in header.split(separator: ";") {
            let pair = part.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard pair.count == 2 else { continue }
            let key = pair[0].trimmingCharacters(in: .whitespacesAndNewlines)
            if key == name {
                return String(pair[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    private enum Keys {
        static let listId = "x.listId"
        static let userAgent = "x.userAgent"
        static let cookieHeader = "x.cookieHeader"
        static let authorizationBearer = "x.authorizationBearer"
        static let guestToken = "x.guestToken"
    }
}
