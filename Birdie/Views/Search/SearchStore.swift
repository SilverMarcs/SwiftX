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

    @ObservationIgnored private let searchTweets: (String) async throws -> [Tweet]
    @ObservationIgnored private let searchUsers: (String) async throws -> [User]

    init(
        searchTweets: @escaping (String) async throws -> [Tweet] = { try await TweetService.searchTweets(query: $0) },
        searchUsers: @escaping (String) async throws -> [User] = { try await TweetService.searchUsers(query: $0) }
    ) {
        self.searchTweets = searchTweets
        self.searchUsers = searchUsers
    }

    func submit() {
        submittedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedScope = scope
        requestID = UUID()
        tweets = []
        users = []
        errorMessage = nil
        hasSearched = false
        isLoading = !submittedQuery.isEmpty
    }

    func clear() {
        query = ""
        submit()
    }

    func load() async {
        guard !submittedQuery.isEmpty else { return }
        let id = requestID
        let query = submittedQuery
        let scope = submittedScope
        isLoading = true
        defer { if requestID == id { isLoading = false } }
        do {
            switch scope {
            case .tweets:
                let results = try await searchTweets(query)
                try Task.checkCancellation()
                guard requestID == id else { return }
                tweets = results
            case .users:
                let results = try await searchUsers(query)
                try Task.checkCancellation()
                guard requestID == id else { return }
                users = results
            }
            hasSearched = true
        } catch {
            guard requestID == id, !Task.isCancelled, !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }
}
