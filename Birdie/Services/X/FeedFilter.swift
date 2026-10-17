import Foundation

enum FeedFilter: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case popular = "Popular"
    case forYou = "For You"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .recent: "clock"
        case .popular: "heart"
        case .forYou: "sparkles"
        }
    }

    var emptyMessage: String {
        switch self {
        case .recent, .popular: "Posts from people you follow will appear here."
        case .forYou: "Recommended posts will appear here."
        }
    }
}
