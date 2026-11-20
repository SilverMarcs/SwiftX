import Foundation

/// Shared bookkeeping for timelines that load one page at a time.
@MainActor
struct XTimelinePagination {
    private(set) var nextCursor: String?
    private(set) var generation = UUID()
    private var consumedCursors = Set<String>()

    mutating func beginRefresh() -> UUID {
        generation = UUID()
        nextCursor = nil
        consumedCursors = []
        return generation
    }

    mutating func finishFirstPage(nextCursor: String?) {
        self.nextCursor = nonempty(nextCursor)
    }

    mutating func advance(after cursor: String, nextCursor: String?) {
        consumedCursors.insert(cursor)
        self.nextCursor = nonempty(nextCursor).flatMap { consumedCursors.contains($0) ? nil : $0 }
    }

    func isCurrent(_ expectedGeneration: UUID) -> Bool {
        generation == expectedGeneration && !Task.isCancelled
    }

    static func uniqueItems<Item: Identifiable>(_ incoming: [Item], excluding existing: [Item] = []) -> [Item] {
        var seen = Set(existing.map(\.id))
        return incoming.filter { seen.insert($0.id).inserted }
    }

    private func nonempty(_ cursor: String?) -> String? {
        cursor.flatMap { $0.isEmpty ? nil : $0 }
    }
}
