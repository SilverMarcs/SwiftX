import Foundation
import Observation
import WebKit

@MainActor
@Observable
final class XSessionStore {
    static let shared = XSessionStore()

    private var collection: XSessionCollection
    @ObservationIgnored private let defaults = UserDefaults.standard
    private(set) var revision = UUID()
    private(set) var isSigningOut = false

    private static let keychainKey = "x.sessions.v2"
    private static let legacyKeychainKey = "x.session.v1"
    private static let expiredAccountsKey = "x.expiredAccountIDs"

    private init() {
        if let saved: XSessionCollection = Self.load(key: Self.keychainKey) {
            collection = saved
        } else if let legacy: XSessionRecord = Self.load(key: Self.legacyKeychainKey) {
            collection = XSessionCollection(records: [legacy], activeAccountID: legacy.account.id)
            // Keep the original until the migration has been durably saved.
            try? Self.save(collection)
        } else {
            collection = XSessionCollection()
        }
        for index in collection.records.indices {
            if expiredAccountIDs.contains(collection.records[index].account.id) {
                collection.records[index].credentials = nil
            }
        }
        if !collection.records.contains(where: { $0.account.id == collection.activeAccountID }) {
            collection.activeAccountID = collection.records.first?.account.id
        }
        Self.removeLegacyWebsiteData()
    }

    var accounts: [XAccount] { collection.records.map(\.account) }
    var activeAccountID: Int? { collection.activeAccountID }
    private var activeRecord: XSessionRecord? {
        collection.records.first { $0.account.id == activeAccountID }
    }
    var account: XAccount? { isAuthenticated ? activeRecord?.account : nil }
    var credentials: XCredentials? { activeRecord?.credentials }
    var isAuthenticated: Bool { credentials?.isValid == true }
    var needsSignIn: Bool { activeRecord != nil && !isAuthenticated }

    func needsSignIn(accountID: Int) -> Bool {
        collection.records.first { $0.account.id == accountID }?.credentials?.isValid != true
    }

    func signIn(account: XAccount, credentials: XCredentials, makeActive: Bool = true) throws {
        guard !isSigningOut, credentials.isValid else { throw XClientError.signedOut }
        let record = XSessionRecord(account: account, credentials: credentials)
        var updated = collection
        if let index = updated.records.firstIndex(where: { $0.account.id == account.id }) {
            updated.records[index] = record
        } else {
            updated.records.append(record)
        }
        if makeActive || updated.activeAccountID == nil { updated.activeAccountID = account.id }
        try Self.save(updated)
        clearExpiration(accountID: account.id)
        let changesActiveSession = updated.activeAccountID != collection.activeAccountID || updated.activeAccountID == account.id
        collection = updated
        if changesActiveSession { resetSessionRevision() }
        for key in ["x.cookieHeader", "x.authorizationBearer", "x.guestToken"] {
            KeychainManager.shared.delete(key: key)
        }
        for key in ["x.listId", "x.userAgent"] { UserDefaults.standard.removeObject(forKey: key) }
    }

    func switchAccount(to accountID: Int) throws {
        guard !isSigningOut,
              let record = collection.records.first(where: { $0.account.id == accountID }),
              record.credentials?.isValid == true else { throw XClientError.signedOut }
        guard activeAccountID != accountID else { return }
        var updated = collection
        updated.activeAccountID = accountID
        try Self.save(updated)
        collection = updated
        resetSessionRevision()
    }

    func removeAccount(id accountID: Int) throws {
        var updated = collection
        updated.records.removeAll { $0.account.id == accountID }
        let removesActiveAccount = updated.activeAccountID == accountID
        if removesActiveAccount {
            updated.activeAccountID = updated.records.first(where: { $0.credentials?.isValid == true })?.account.id
                ?? updated.records.first?.account.id
        }
        try Self.save(updated)
        clearExpiration(accountID: accountID)
        collection = updated
        if removesActiveAccount { resetSessionRevision() }
    }

    func expire(ifRevision expected: UUID) {
        guard revision == expected,
              let index = collection.records.firstIndex(where: { $0.account.id == activeAccountID }) else { return }
        let accountID = collection.records[index].account.id
        // A non-secret invalidation marker also prevents reuse if Keychain saving fails.
        let expired = expiredAccountIDs.union([accountID])
        defaults.set(Array(expired), forKey: Self.expiredAccountsKey)
        collection.records[index].credentials = nil
        try? Self.save(collection)
        resetSessionRevision()
    }

    func signOut() async {
        guard !isSigningOut, let activeAccountID else { return }
        isSigningOut = true
        defer { isSigningOut = false }
        // Keep this compatibility entry point; the Accounts screen reports removal errors.
        try? removeAccount(id: activeAccountID)
    }

    private func resetSessionRevision() {
        revision = UUID()
        URLCache.shared.removeAllCachedResponses()
    }

    private var expiredAccountIDs: Set<Int> {
        Set(defaults.array(forKey: Self.expiredAccountsKey) as? [Int] ?? [])
    }

    private func clearExpiration(accountID: Int) {
        defaults.set(Array(expiredAccountIDs.subtracting([accountID])), forKey: Self.expiredAccountsKey)
    }

    /// Sign-in used to share one persistent web store, which would hand Add Account the
    /// active account's cookies. Each attempt now uses a throwaway store; drop the old one once.
    private static func removeLegacyWebsiteData() {
        let key = "x.removedLegacyWebsiteData"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        let identifier = UUID(uuid: (0x23, 0x57, 0x32, 0x11, 0x78, 0x9a, 0x4b, 0x11, 0x83, 0x01, 0x15, 0x91, 0x42, 0xa2, 0x39, 0x61))
        // Clear rather than remove: `WKWebsiteDataStore.remove(forIdentifier:)` crashes
        // inside WebKit when called this early in launch.
        let store = WKWebsiteDataStore(forIdentifier: identifier)
        Task {
            await store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    private static func save(_ collection: XSessionCollection) throws {
        let data = try JSONEncoder().encode(collection)
        try KeychainManager.shared.save(key: keychainKey, data: String(decoding: data, as: UTF8.self))
        KeychainManager.shared.delete(key: legacyKeychainKey)
    }

    private static func load<Value: Decodable>(key: String) -> Value? {
        guard let saved = KeychainManager.shared.load(key: key), let data = saved.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }
}
