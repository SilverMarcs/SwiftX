struct XRelationship: Equatable, Sendable {
    let isFollowing: Bool
    let isRequested: Bool

    init(isFollowing: Bool, isRequested: Bool = false) {
        self.isFollowing = isFollowing
        self.isRequested = isRequested
    }
}
