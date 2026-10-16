import Foundation
import Observation

@MainActor
@Observable
final class SearchStore {
    var query = ""
    var scope = SearchScope.posts
    private(set) var posts: [Post] = []
    private(set) var users: [User] = []
    private(set) var isLoading = false
    private(set) var error: String?
    private var generation = UUID()

    func clear() {
        generation = UUID()
        query = ""
        posts = []
        users = []
        error = nil
        isLoading = false
    }

    func search() async {
        generation = UUID()
        let generation = generation
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        posts = []
        users = []
        error = nil
        guard !query.isEmpty else { isLoading = false; return }
        isLoading = true
        defer { if self.generation == generation { isLoading = false } }
        do {
            switch scope {
            case .posts:
                let result = try await XClient.shared.searchPosts(query)
                try Task.checkCancellation()
                guard self.generation == generation else { return }
                posts = result
            case .people:
                let result = try await XClient.shared.searchUsers(query)
                try Task.checkCancellation()
                guard self.generation == generation else { return }
                users = result
            }
        } catch { if self.generation == generation, !Task.isCancelled { self.error = error.localizedDescription } }
    }
}
