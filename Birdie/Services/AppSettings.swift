import Foundation
import Observation

@MainActor
@Observable
final class XAuthStore {
    static let shared = XAuthStore()
    private(set) var session = XSession(cookie: "", authorization: "", userAgent: "")
    private(set) var revision = UUID()
    private(set) var loadError: String?

    var isAuthenticated: Bool { session.isComplete }

    init() {
        do {
            if let value = try KeychainManager.shared.load(key: "x.session") {
                session = try JSONDecoder().decode(XSession.self, from: Data(value.utf8))
            } else {
                // Read existing installations without exposing or requiring re-entry of credentials.
                session = XSession(
                    cookie: try KeychainManager.shared.load(key: "x.cookieHeader") ?? "",
                    authorization: try KeychainManager.shared.load(key: "x.authorizationBearer") ?? "",
                    userAgent: UserDefaults.standard.string(forKey: "x.userAgent") ?? ""
                )
            }
        } catch {
            loadError = "Your saved session couldn’t be read. Check Keychain access, then reopen Birdie or add your session again."
        }
    }

    func save(_ value: XSession) throws {
        guard value.isComplete else { throw XAPIError.missingSession }
        let normalized = XSession(cookie: value.normalizedCookie, authorization: value.normalizedAuthorization, userAgent: value.userAgent.trimmingCharacters(in: .whitespacesAndNewlines))
        let data = try JSONEncoder().encode(normalized)
        try KeychainManager.shared.save(key: "x.session", data: String(decoding: data, as: UTF8.self))
        session = normalized
        loadError = nil
        revision = UUID()
    }

    func signOut() throws {
        for key in ["x.session", "x.cookieHeader", "x.authorizationBearer", "x.guestToken"] {
            try KeychainManager.shared.delete(key: key)
        }
        session = XSession(cookie: "", authorization: "", userAgent: "")
        loadError = nil
        revision = UUID()
    }
}
