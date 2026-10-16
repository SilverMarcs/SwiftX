import Foundation
import Observation

@MainActor
@Observable
final class PostDetailStore {
    private(set) var replies: [Post] = []
    private(set) var isLoading = false
    private(set) var error: String?
    private var generation = UUID()

    func load(postID: String) async {
        generation = UUID()
        let generation = generation
        isLoading = true
        defer { if self.generation == generation { isLoading = false } }
        do {
            let replies = try await XClient.shared.replies(postID: postID)
            try Task.checkCancellation()
            guard self.generation == generation else { return }
            self.replies = replies
            error = nil
        } catch {
            if self.generation == generation, !Task.isCancelled { self.error = error.localizedDescription }
        }
    }
}
