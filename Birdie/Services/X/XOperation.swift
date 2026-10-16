import Foundation

/// Public operation identifiers shipped by X's frontend. Keep changes here when
/// X updates persisted queries; they are not developer API keys.
nonisolated enum XOperation {
    case home
    case userPosts
    case profile
    case detail
    case search

    var modern: Bool { self == .home || self == .search || self == .detail }

    var path: String {
        switch self {
        case .home: "pibe9AwyZEvDRmaNFEc8BA/HomeTimelineQuery"
        case .userPosts: "SXVCYB8XHSS25nzIljNtZA/UserTweets"
        case .profile: "xvmVfRLmnr1alc5f2dib0Q/UserByRestId"
        case .detail: "IeSHGHNHx_Y4LhXebl2oKw/TweetDetail"
        case .search: "G1QWH-tqNJrBp7C-Q3espg/SearchByRawQuery"
        }
    }

    var baseURL: String { modern ? "https://api.x.com/graphql" : "https://x.com/i/api/graphql" }
}
