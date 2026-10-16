import Foundation

@MainActor
final class SeenPostStore {
    private let defaults: UserDefaults
    private let limit: Int
    private var key: String?
    private var known: [String] = []
    private var knownIDs = Set<String>()
    private(set) var pending: [String] = []

    init(defaults: UserDefaults = .standard, limit: Int = 1_500) {
        self.defaults = defaults
        self.limit = max(1, limit)
    }

    func configure(accountKey: String) {
        let key = "x.seenPosts.\(accountKey)"
        guard self.key != key else { return }
        self.key = key
        known = Array((defaults.stringArray(forKey: key) ?? []).suffix(limit))
        knownIDs = Set(known)
        pending = Array((defaults.stringArray(forKey: key + ".pending") ?? []).suffix(limit))
    }

    func markVisible(_ id: String) {
        guard key != nil, knownIDs.insert(id).inserted else { return }
        known.append(id)
        pending.append(id)
        if known.count > limit { knownIDs.remove(known.removeFirst()) }
        if pending.count > limit { pending.removeFirst(pending.count - limit) }
        persist()
    }

    /// Acknowledge the request's snapshot, retaining posts seen while it was in flight.
    func acknowledge(_ sent: [String]) {
        let sentIDs = Set(sent)
        pending.removeAll { sentIDs.contains($0) }
        persist()
    }

    private func persist() {
        guard let key else { return }
        defaults.set(known, forKey: key)
        defaults.set(pending, forKey: key + ".pending")
    }
}
