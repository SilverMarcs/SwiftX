import Foundation

enum FollowingSort: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case popular = "Popular"

    var id: Self { self }
}
