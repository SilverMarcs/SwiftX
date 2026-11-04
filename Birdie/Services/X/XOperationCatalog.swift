import Foundation

/// One catalogue drives seeds, aliases, request policy, and public-asset discovery.
enum XOperationCatalog {
    private static let relayDefaults = [
        "__relay_internal__pv__xclientsfeaturesappviewerisloggedinrelayprovider": true,
        "__relay_internal__pv__xclientsfeaturestranslationnoteautotranslationenabledrelayprovider": false
    ]

    /// Relay requires every provided variable declared by the mutation; only the logged-in flag is enabled.
    private static let createTweetProviders = relayDefaults.merging([
        "__relay_internal__pv__xclientsfeaturestweetcomponentsgrokanalyzepostrelayprovider": false,
        "__relay_internal__pv__xclientsfeaturestranslationgroktranslatedpostenabledrelayprovider": false,
        "__relay_internal__pv__liveeventpostcontextenabledrelayprovider": false,
        "__relay_internal__pv__sportspostcontextenabledrelayprovider": false
    ]) { current, _ in current }

    private static let articleFieldToggles = ["withArticleRichContentState": false, "withArticlePlainText": false]

    static let definitions: [XOperationDefinition] = [
        .init("HomeLatestTimelineQuery", canonicalName: "HomeLatestTimeline", queryID: "Lk_3-p7nX68Uq1VFYo0m0g", relayVariables: relayDefaults, assetPrefixes: ["home-"]),
        .init("HomeLatestTimeline", method: "POST", isRelay: false, assetPrefixes: ["home-"]),
        .init("HomeTimelineQuery", canonicalName: "HomeTimeline", queryID: "msrNpQ16xpmF5Um0O4Y_Zg", relayVariables: relayDefaults, assetPrefixes: ["home-"]),
        .init("HomeTimeline", isRelay: false, fieldToggles: articleFieldToggles, assetPrefixes: ["home-"]),
        .init("UserByScreenName", queryID: "yvm61GcJCIpqEwe_3RBccw", relayVariables: relayDefaults, fieldToggles: articleFieldToggles, assetPrefixes: ["UserByScreenName.", "user-profile-", "_profile-"]),
        .init("UserByRestId", queryID: "xvmVfRLmnr1alc5f2dib0Q", isRelay: false, fieldToggles: articleFieldToggles, assetPrefixes: ["user-profile-", "_profile-"]),
        .init("UserOriginalsTimeline", canonicalName: "UserTweets", queryID: "U9W6pwnA7XeTBja_ql4lbw", relayVariables: relayDefaults, assetPrefixes: ["user-posts-"]),
        .init("UserTweets", isRelay: false, fieldToggles: articleFieldToggles, assetPrefixes: ["user-posts-"]),
        .init("TweetDetail", queryID: "mw1YqNf95jXRYKKJMGKzgw", relayVariables: relayDefaults, fieldToggles: articleFieldToggles, assetPrefixes: ["conversation-"]),
        .init("SearchByRawQuery", queryID: "mSbI6UIYLPd7b9qkaJ6SAA", relayVariables: relayDefaults, assetPrefixes: ["search-results", "search-"]),
        .init("viewerQuery", queryID: "fJ_6rPf08JjvZdq-D2jACg", relayVariables: relayDefaults, assetPrefixes: ["user-profile-"]),
        .init("followUserMutation", queryID: "m5VXpPA-MH4DH7epCa7hCg", method: "POST", isMutation: true, assetPrefixes: ["follow-user-"]),
        .init("unfollowUserMutation", queryID: "RjGnpAQuMmcqXSjoCR7t6w", method: "POST", isMutation: true, assetPrefixes: ["unfollow-user-"]),
        .init("createTweetMutation", queryID: "1-Q_HG-1HRINbimEaI8MPQ", method: "POST", isMutation: true,
              relayVariables: createTweetProviders, assetPrefixes: ["media-upload-button-"])
    ]

    private static let byName = Dictionary(uniqueKeysWithValues: definitions.map { ($0.name, $0) })
    private static let bootPrefixes = ["entry-client", "startup-dynamic", "startup-"]

    static func definition(named name: String) -> XOperationDefinition? { byName[name] }

    static func canonicalName(_ name: String) -> String { byName[name]?.canonicalName ?? name }

    /// Filtering and ordering use this same list so a discoverable route cannot lose priority support.
    static func assetPrefixes(for requestedNames: Set<String>) -> [String] {
        let preferred = definitions.filter { requestedNames.contains($0.canonicalName) }.flatMap(\.assetPrefixes)
        var seen = Set<String>()
        let ordered = Array(bootPrefixes.prefix(2)) + preferred + Array(bootPrefixes.dropFirst(2)) + definitions.flatMap(\.assetPrefixes)
        return ordered.filter { seen.insert($0).inserted }
    }
}
