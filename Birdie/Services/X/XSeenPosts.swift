import Foundation

/// Tells X which home feed posts were shown, so its ranking stops repeating them.
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

    private init() {
        let stored = UserDefaults.standard.dictionary(forKey: Self.key)
        accountID = stored?["account"] as? Int
        queue = stored?["ids"] as? [String] ?? []
    }

    func markSeen(_ tweet: Tweet) {
        let id = String(tweet.id)
        guard syncAccount(), !queue.contains(id) else { return }
        queue.append(id)
        if queue.count > Self.limit { queue.removeFirst(queue.count - Self.limit) }
        save()
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

    /// Starts a fresh queue when the active account changes, so posts never reach another account.
    private func syncAccount() -> Bool {
        guard let active = XSessionStore.shared.account?.id else { return false }
        if active != accountID {
            accountID = active
            queue = []
        }
        return true
    }

    private func save() {
        UserDefaults.standard.set(["account": accountID ?? 0, "ids": queue], forKey: Self.key)
    }
}
