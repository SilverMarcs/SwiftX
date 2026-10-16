import Foundation

nonisolated struct User: Hashable, Sendable, Identifiable {
    let id: String
    let username: String
    let name: String
    var bio: String?
    var followersCount: Int?
    var followingCount: Int?
    var location: String?
    var avatarURL: URL?
    var bannerURL: URL?
    var isVerified = false
    var isLegacyVerified = false
    var isFollowing: Bool?
    var links: [PostLink] = []

    var webURL: URL? { URL(string: "https://x.com/\(username)") }
}
