import Foundation
import Observation

@MainActor
@Observable
final class ProfileStore {
    private(set) var profile: User?
    private(set) var posts: [Post] = []
    private(set) var isLoading = false
    private(set) var error: String?
    private var generation = UUID()

    func load(userID: String) async {
        generation = UUID()
        let generation = generation
        isLoading = true
        defer { if self.generation == generation { isLoading = false } }
        async let profile = XClient.shared.profile(userID: userID)
        async let posts = XClient.shared.posts(userID: userID)
        var errors: [String] = []
        do {
            let value = try await profile
            try Task.checkCancellation()
            guard self.generation == generation else { return }
            self.profile = value
        } catch { if !Task.isCancelled { errors.append(error.localizedDescription) } }
        do {
            let value = try await posts
            try Task.checkCancellation()
            guard self.generation == generation else { return }
            self.posts = value
        } catch { if !Task.isCancelled { errors.append(error.localizedDescription) } }
        if self.generation == generation { error = errors.first }
    }
}
