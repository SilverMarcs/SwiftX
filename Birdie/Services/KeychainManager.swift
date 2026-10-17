import Foundation
import Security

@MainActor
final class KeychainManager {
    static let shared = KeychainManager()
    private let service = "com.SilverMarcs.Birdie"

    private init() {}

    func save(key: String, data: String) throws {
        guard let keyData = data.data(using: .utf8) else {
            throw XClientError.credentialStorage
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let identity: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemUpdate(identity as CFDictionary, [kSecValueData as String: keyData] as CFDictionary)
        if status == errSecItemNotFound {
            guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else { throw XClientError.credentialStorage }
        } else if status != errSecSuccess {
            throw XClientError.credentialStorage
        }
    }

    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == noErr, let data = dataTypeRef as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
