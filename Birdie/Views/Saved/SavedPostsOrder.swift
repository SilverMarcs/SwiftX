import Foundation

/// How the Saved tab arranges posts. X itself only offers newest-saved-first.
enum SavedPostsOrder: String, CaseIterable, Identifiable {
    case recent = "Recently Saved"
    case shuffled = "Shuffled"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .recent: "clock"
        case .shuffled: "shuffle"
        }
    }
}
