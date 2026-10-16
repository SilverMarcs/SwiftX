import Foundation
import Security

@MainActor
final class KeychainManager {
    static let shared = KeychainManager()
    private let service = "com.SilverMarcs.Birdie"

    func load(key: String) throws -> String? {
        var query = query(key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw XAPIError.keychain(status) }
        guard let data = result as? Data else { throw XAPIError.responseChanged }
        return String(data: data, encoding: .utf8)
    }

    func save(key: String, data: String) throws {
        let attributes: [String: Any] = [kSecValueData as String: Data(data.utf8)]
        let status = SecItemUpdate(query(key) as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var item = query(key)
            item.merge(attributes) { _, new in new }
            item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            let added = SecItemAdd(item as CFDictionary, nil)
            guard added == errSecSuccess else { throw XAPIError.keychain(added) }
        } else if status != errSecSuccess {
            throw XAPIError.keychain(status)
        }
    }

    func delete(key: String) throws {
        let status = SecItemDelete(query(key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw XAPIError.keychain(status) }
    }

    private func query(_ key: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: key]
    }
}
