import Foundation

/// All accounts and the selected account are saved together in the device Keychain.
struct XSessionCollection: Codable {
    var records: [XSessionRecord] = []
    var activeAccountID: Int?
}
