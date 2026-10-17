import Foundation
import Observation
import WebKit

@MainActor
@Observable
final class XSessionStore {
    static let shared = XSessionStore()

    private(set) var account: XAccount?
    private(set) var credentials: XCredentials?
    private(set) var revision = UUID()
    private(set) var needsSignIn = false
    private(set) var isSigningOut = false

    // Separate from Safari and from any other web content shown by Birdie.
    static let websiteDataStore = WKWebsiteDataStore(forIdentifier: UUID(uuid: (0x23, 0x57, 0x32, 0x11, 0x78, 0x9a, 0x4b, 0x11, 0x83, 0x01, 0x15, 0x91, 0x42, 0xa2, 0x39, 0x61)))
    private static let keychainKey = "x.session.v1"

    private init() {
        if let saved = Self.loadRecord(), saved.credentials.isValid {
            account = saved.account
            credentials = saved.credentials
        }
    }

    var isAuthenticated: Bool { account != nil && credentials?.isValid == true }

    func signIn(account: XAccount, credentials: XCredentials) throws {
        guard !isSigningOut else { throw XClientError.signedOut }
        guard credentials.isValid else { throw XClientError.signedOut }
        let record = XSessionRecord(account: account, credentials: credentials)
        let data = try JSONEncoder().encode(record)
        try KeychainManager.shared.save(key: Self.keychainKey, data: String(decoding: data, as: UTF8.self))
        self.account = account
        self.credentials = credentials
        needsSignIn = false
        revision = UUID()
        // Remove credentials used by the retired manual setup.
        for key in ["x.cookieHeader", "x.authorizationBearer", "x.guestToken"] {
            KeychainManager.shared.delete(key: key)
        }
        for key in ["x.listId", "x.userAgent"] { UserDefaults.standard.removeObject(forKey: key) }
    }

    func expire(ifRevision expected: UUID) {
        guard revision == expected else { return }
        clear()
        needsSignIn = true
    }

    func signOut() async {
        guard !isSigningOut else { return }
        isSigningOut = true
        defer { isSigningOut = false }
        clear()
        needsSignIn = false
        await Self.websiteDataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
    }

    private func clear() {
        account = nil
        credentials = nil
        revision = UUID()
        KeychainManager.shared.delete(key: Self.keychainKey)
        for key in ["x.cookieHeader", "x.authorizationBearer", "x.guestToken"] {
            KeychainManager.shared.delete(key: key)
        }
        URLCache.shared.removeAllCachedResponses()
    }

    private static func loadRecord() -> XSessionRecord? {
        guard let saved = KeychainManager.shared.load(key: keychainKey), let data = saved.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(XSessionRecord.self, from: data)
    }
}
