import Foundation

struct XSessionRecord: Codable {
    let account: XAccount
    var credentials: XCredentials?
}
