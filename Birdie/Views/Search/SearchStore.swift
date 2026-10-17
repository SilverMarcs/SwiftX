import Foundation
import Observation

@MainActor
@Observable
final class SearchStore {
    var query = ""
    var scope: SearchScope = .users
    private(set) var submittedQuery = ""
    private(set) var tweets: [Tweet] = []
    private(set) var users: [User] = []
    private var loadingScopes: Set<SearchScope> = []
    private var errors: [SearchScope: String] = [:]

    var isLoading: Bool { loadingScopes.contains(scope) }
    var hasSearched: Bool { !submittedQuery.isEmpty }
    var errorMessage: String? { errors[scope] }
    var isEmpty: Bool {
        switch scope {
        case .tweets: tweets.isEmpty
        case .users: users.isEmpty
        }
    }

    private func clearResults() {
        submittedQuery = ""
        tweets = []
        users = []
        errors = [:]
    }

    func clear() {
        query = ""
        clearResults()
    }

    func submit() async {
        let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard loadingScopes.isEmpty, XSessionStore.shared.isAuthenticated, !searchQuery.isEmpty else { return }

        if submittedQuery != searchQuery {
            clearResults()
            submittedQuery = searchQuery
        }
        await search(query: searchQuery)
    }

    func loadIfNeeded() async {
        guard isEmpty, !submittedQuery.isEmpty else { return }
        await search(query: submittedQuery)
    }

    private func search(query searchQuery: String) async {
        let session = XSessionStore.shared
        let searchScope = scope
        guard session.isAuthenticated, !loadingScopes.contains(searchScope) else { return }
        let revision = session.revision
        loadingScopes.insert(searchScope)
        errors[searchScope] = nil
        defer { loadingScopes.remove(searchScope) }

        do {
            switch searchScope {
            case .tweets:
                let results = try await XClient.shared.searchTweets(query: searchQuery)
                guard session.revision == revision, submittedQuery == searchQuery else { return }
                tweets = results
            case .users:
                let results = try await XClient.shared.searchUsers(query: searchQuery)
                guard session.revision == revision, submittedQuery == searchQuery else { return }
                users = results
            }
        } catch {
            guard session.revision == revision, submittedQuery == searchQuery else { return }
            errors[searchScope] = error.localizedDescription
        }
    }
}
