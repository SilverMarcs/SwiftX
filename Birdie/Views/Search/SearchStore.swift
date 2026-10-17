import Foundation
import Observation

@MainActor
@Observable
final class SearchStore {
    var query = ""
    var scope: SearchScope = .tweets
    private(set) var requestID = UUID()
    private(set) var submittedQuery = ""
    private(set) var isLoading = false
    private(set) var hasSearched = false
    private(set) var errorMessage: String?
    private(set) var tweets: [Tweet] = []
    private(set) var users: [User] = []
    private var submittedScope: SearchScope = .tweets
    @ObservationIgnored private var sessionRevision: UUID?

    func submit() {
        let session = XSessionStore.shared
        sessionRevision = session.revision
        submittedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedScope = scope
        requestID = UUID()
        tweets = []
        users = []
        errorMessage = nil
        hasSearched = false
        isLoading = session.isAuthenticated && !submittedQuery.isEmpty
    }

    func clear() {
        query = ""
        submit()
    }

    func load() async {
        let session = XSessionStore.shared
        let revision = session.revision
        guard !submittedQuery.isEmpty, session.isAuthenticated,
              sessionRevision == session.revision, !Task.isCancelled else { return }
        let id = requestID
        let query = submittedQuery
        let scope = submittedScope
        isLoading = true
        defer { if requestID == id { isLoading = false } }
        do {
            switch scope {
            case .tweets:
                let results = try await XClient.shared.searchTweets(query: query)
                try Task.checkCancellation()
                guard isCurrent(id, revision: revision) else { return }
                tweets = results
            case .users:
                let results = try await XClient.shared.searchUsers(query: query)
                try Task.checkCancellation()
                guard isCurrent(id, revision: revision) else { return }
                users = results
            }
            hasSearched = true
        } catch {
            guard isCurrent(id, revision: revision), !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }

    private func isCurrent(_ id: UUID, revision: UUID) -> Bool {
        let session = XSessionStore.shared
        return requestID == id && session.revision == revision && session.isAuthenticated && !Task.isCancelled
    }
}
