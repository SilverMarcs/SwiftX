// Compile with Birdie's core sources using -parse-as-library. Supply XSession
// JSON on stdin; this read-only probe never prints credentials or post contents.
import Foundation

@main
struct VerifyLive {
    @MainActor private static var hasErrors = false
    @MainActor
    static func main() async {
        do {
            let credentials = try JSONDecoder().decode(XSession.self, from: FileHandle.standardInput.readDataToEndOfFile())
            let client = XClient(credentials: { credentials })
            var cursor: String?
            var ids = Set<String>()
            var sample: Post?
            let ancillaryOnly = CommandLine.arguments.contains("--ancillary")
            for pageNumber in 1...(ancillaryOnly ? 1 : 3) {
                let page = try await client.home(cursor: cursor, seenIDs: [])
                let new = page.entries.filter { ids.insert($0.post.id).inserted }
                if sample == nil { sample = page.entries.first(where: { $0.post.replyCount > 0 })?.post ?? page.entries.first?.post }
                emit(["stage": "home", "page": pageNumber, "posts": page.entries.count, "newPosts": new.count, "hasCursor": page.nextCursor != nil, "quotes": page.entries.filter { $0.post.quotedPost != nil }.count, "media": page.entries.filter { $0.post.media != nil }.count, "avatars": page.entries.filter { $0.post.user.avatarURL != nil }.count])
                cursor = page.nextCursor
                if cursor == nil { break }
            }
            if !ancillaryOnly {
                let refresh = try await client.home(seenIDs: Array(ids.prefix(3)), refreshing: true)
                emit(["stage": "refresh", "posts": refresh.entries.count, "hasCursor": refresh.nextCursor != nil])
            }
            if let sample {
                do { let profile = try await client.profile(userID: sample.user.id); emit(["stage": "profile", "hasAvatar": profile.avatarURL != nil, "hasBio": profile.bio != nil]) }
                catch { emit(["stage": "profile", "error": error.localizedDescription]) }
                do { let posts = try await client.posts(userID: sample.user.id); emit(["stage": "profilePosts", "posts": posts.count]) }
                catch { emit(["stage": "profilePosts", "error": error.localizedDescription]) }
                do { let posts = try await client.replies(postID: sample.id); emit(["stage": "replies", "posts": posts.count]) }
                catch { emit(["stage": "replies", "error": error.localizedDescription]) }
            }
            do { let posts = try await client.searchPosts("from:xdevelopers"); emit(["stage": "searchPosts", "posts": posts.count]) }
            catch { emit(["stage": "searchPosts", "error": error.localizedDescription]) }
            do { let users = try await client.searchUsers("xdevelopers"); emit(["stage": "searchUsers", "users": users.count]) }
            catch { emit(["stage": "searchUsers", "error": error.localizedDescription]) }
        } catch { emit(["stage": "failed", "error": error.localizedDescription]) }
        if hasErrors { exit(EXIT_FAILURE) }
    }

    @MainActor
    static func emit(_ value: [String: Any]) {
        if value["error"] != nil { hasErrors = true }
        if let data = try? JSONSerialization.data(withJSONObject: value, options: .sortedKeys) {
            print(String(decoding: data, as: UTF8.self))
        }
    }
}
