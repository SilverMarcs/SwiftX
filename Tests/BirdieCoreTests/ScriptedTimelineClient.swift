@testable import BirdieCore

@MainActor
final class ScriptedTimelineClient: TimelineLoading {
    var requests: [(String?, [String], Bool)] = []
    var handler: (String?, [String], Bool) async throws -> TimelinePage = { _, _, _ in Fixtures.page([]) }

    func home(cursor: String?, seenIDs: [String], refreshing: Bool) async throws -> TimelinePage {
        requests.append((cursor, seenIDs, refreshing))
        return try await handler(cursor, seenIDs, refreshing)
    }
}
