nonisolated struct TimelineEntry: Hashable, Sendable, Identifiable {
    let id: String
    let post: Post
    var context: String?
    var isPromoted = false
    var conversationID: String?
}
