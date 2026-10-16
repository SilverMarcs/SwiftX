nonisolated struct Video: Hashable, Sendable {
    let thumbnailUrl: String
    let variants: [VideoVariant]
    let duration: Int?
    let views: Int?
}
