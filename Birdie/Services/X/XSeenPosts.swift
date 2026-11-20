import Foundation

/// Queues posts shown in the home feed or full-screen video viewer for reporting to X.
///
/// Like the web client, posts wait here only until the next home timeline request sends
/// them as `seenTweetIds`, then they're dropped. The queue belongs to one account at a time.
@MainActor
final class XSeenPosts {
    static let shared = XSeenPosts()

    private static let key = "x.seenTweetIds"
    // Keeps the GET request short; a request goes out about every 20 posts anyway.
    private static let limit = 200

    private var accountID: Int?
    private var queue: [String] = []
    private var watchedVideoIDs: [String] = []

    private init() {
        let stored = UserDefaults.standard.dictionary(forKey: Self.key)
        accountID = stored?["account"] as? Int
        queue = stored?["ids"] as? [String] ?? []
        watchedVideoIDs = stored?["watchedVideoIDs"] as? [String] ?? []
    }

    func markSeen(_ tweet: Tweet) {
        markSeen(id: String(tweet.id))
    }

    private func markSeen(id: String) {
        guard syncAccount(), !queue.contains(id) else { return }
        queue.append(id)
        if queue.count > Self.limit { queue.removeFirst(queue.count - Self.limit) }
        save()
    }

    /// Called only when a full-screen video becomes the current page.
    func markVideoSeen(id: String) {
        guard syncAccount() else { return }
        if !watchedVideoIDs.contains(id) {
            watchedVideoIDs.append(id)
            if watchedVideoIDs.count > 1_000 {
                watchedVideoIDs.removeFirst(watchedVideoIDs.count - 1_000)
            }
        }
        markSeen(id: id)
        save()
    }

    func hasSeenVideo(id: String) -> Bool {
        syncAccount() && watchedVideoIDs.contains(id)
    }

    /// The posts the next home timeline request should report.
    func pending() -> [String] {
        syncAccount() ? queue : []
    }

    /// Drops posts X has accepted, keeping any marked while the request was in flight.
    func remove(_ sent: [String]) {
        guard !sent.isEmpty, syncAccount() else { return }
        let sent = Set(sent)
        queue.removeAll(where: sent.contains)
        save()
    }

    /// Clears queued posts and watched-video history when the active account changes.
    private func syncAccount() -> Bool {
        guard let active = XSessionStore.shared.account?.id else { return false }
        if active != accountID {
            accountID = active
            queue = []
            watchedVideoIDs = []
        }
        return true
    }

    private func save() {
        UserDefaults.standard.set(["account": accountID ?? 0, "ids": queue, "watchedVideoIDs": watchedVideoIDs], forKey: Self.key)
    }
}
