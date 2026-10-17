import Foundation

struct XAccount: Codable, Equatable {
    let id: Int
    let username: String
    let displayName: String
    let profileImageURL: String?
}
