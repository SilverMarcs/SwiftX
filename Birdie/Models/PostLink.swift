import Foundation

nonisolated struct PostLink: Hashable, Sendable {
    let url: URL
    let label: String
}
