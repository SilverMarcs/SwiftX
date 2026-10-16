import Foundation

/// App data, independent of the wire format used by X's web clients.
nonisolated struct Post: Hashable, Sendable, Identifiable {
    let id: String
    let user: User
    var date: Date?
    var text = ""
    var replyCount = 0
    var repostCount = 0
    var likeCount = 0
    var bookmarkCount = 0
    var viewCount: Int?
    var links: [PostLink] = []
    var media: Media?
    var replyToID: String?
    var quote: PostReference?
    var repost: PostReference?

    var quotedPost: Post? { quote?.post }
    var repostedPost: Post? { repost?.post }
    var parsedContent: String { String.parseContent(text) }
    var webURL: URL? { URL(string: "https://x.com/i/status/\(id)") }
}
