/// Indirection allows quotes and reposts to reuse the same post model.
nonisolated indirect enum PostReference: Hashable, Sendable {
    case post(Post)

    var post: Post {
        switch self { case .post(let post): post }
    }
}
