@MainActor
protocol TimelineLoading {
    func home(cursor: String?, seenIDs: [String], refreshing: Bool) async throws -> TimelinePage
}
