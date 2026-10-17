import Foundation
import Observation

@MainActor
@Observable
final class XProfileStore {
    // User equality compares IDs; observing the response also publishes updated profile fields.
    private var profile: XProfile?
    private(set) var tweets: [Tweet] = []
    private(set) var relationship: XRelationship?
    private(set) var isLoading = false
    private(set) var isMutating = false
    private(set) var profileErrorMessage: String?
    private(set) var tweetsErrorMessage: String?
    private(set) var relationshipErrorMessage: String?

    @ObservationIgnored private let initialUser: User
    @ObservationIgnored private var sessionRevision: UUID?
    @ObservationIgnored private var requestID = UUID()

    init(user: User) {
        initialUser = user
    }

    var user: User { profile?.user ?? initialUser }

    var isOwnAccount: Bool {
        XSessionStore.shared.account?.id == user.id
    }

    var canChangeFollowing: Bool {
        let session = XSessionStore.shared
        return session.isAuthenticated && session.revision == sessionRevision
            && !isOwnAccount && relationship != nil && profileErrorMessage == nil && !isLoading && !isMutating
    }

    var followButtonTitle: String {
        guard let relationship else { return "Follow" }
        if relationship.isRequested { return "Requested" }
        return relationship.isFollowing ? "Unfollow" : "Follow"
    }

    var followAccessibilityLabel: String {
        if relationship?.isRequested == true { return "Cancel follow request for @\(user.username)" }
        return "\(followButtonTitle) @\(user.username)"
    }

    func load() async {
        let session = XSessionStore.shared
        let revision = session.revision
        if sessionRevision != session.revision {
            invalidate()
            sessionRevision = session.revision
        }
        guard session.isAuthenticated, !isLoading, !isMutating else { return }
        let id = UUID()
        requestID = id
        isLoading = true
        profileErrorMessage = nil
        tweetsErrorMessage = nil
        defer { if requestID == id { isLoading = false } }

        do {
            let profile = try await XClient.shared.fetchProfile(userID: user.id, username: user.username)
            guard isCurrent(id, revision: revision) else { return }
            self.profile = profile
            relationship = profile.relationship
            relationshipErrorMessage = nil
        } catch {
            guard isCurrent(id, revision: revision), !(error is CancellationError) else { return }
            profileErrorMessage = error.localizedDescription
        }

        do {
            let result = try await XClient.shared.fetchUserTweets(userID: user.id, username: user.username)
            guard isCurrent(id, revision: revision) else { return }
            tweets = result
        } catch {
            guard isCurrent(id, revision: revision), !(error is CancellationError) else { return }
            tweetsErrorMessage = error.localizedDescription
        }
    }

    func toggleFollowing() async {
        guard canChangeFollowing, let relationship else { return }
        let id = requestID
        let revision = XSessionStore.shared.revision
        let shouldFollow = !relationship.isFollowing && !relationship.isRequested
        isMutating = true
        relationshipErrorMessage = nil
        defer { if requestID == id { isMutating = false } }

        do {
            let result = try await XClient.shared.setFollowing(userID: user.id, following: shouldFollow, username: user.username)
            guard isCurrent(id, revision: revision) else { return }
            self.relationship = result
        } catch {
            guard isCurrent(id, revision: revision), !(error is CancellationError) else { return }
            relationshipErrorMessage = error.localizedDescription
        }
    }

    private func invalidate() {
        requestID = UUID()
        isLoading = false
        isMutating = false
        relationshipErrorMessage = nil
        profile = nil
        relationship = nil
        tweets = []
        profileErrorMessage = nil
        tweetsErrorMessage = nil
    }

    private func isCurrent(_ id: UUID, revision: UUID) -> Bool {
        let session = XSessionStore.shared
        return requestID == id && session.revision == revision && session.isAuthenticated && !Task.isCancelled
    }
}
