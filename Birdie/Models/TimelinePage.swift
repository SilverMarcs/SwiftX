nonisolated struct TimelinePage: Sendable {
    var entries: [TimelineEntry]
    var nextCursor: String?
    var isTerminated = false
}
