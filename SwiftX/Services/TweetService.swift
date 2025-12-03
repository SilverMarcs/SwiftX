//  TweetService.swift
//  SwiftX
//

import Foundation

struct TweetService {
    static func fetchTweets() async throws -> [Tweet] {
        let tweets = try await TWScrapeClient.shared.fetchListTimeline()
        return filterTweets(tweets)
    }

    static func fetchUserTweets(userId: Int) async throws -> [Tweet] {
        let tweets = try await TWScrapeClient.shared.fetchUserTweets(userId: userId)
        return filterTweets(tweets)
    }

    private static func filterTweets(_ tweets: [Tweet]) -> [Tweet] {
        return tweets.filter { tweet in
            // Check if:
            // - it's not a reply AND
            // - not quoted in any other tweet AND
            // - not retweeted in any other tweet
//            tweet.inReplyToTweetId == nil &&
            !tweets.contains { $0.quotedTweet?.id == tweet.id } &&
            !tweets.contains { $0.retweetedTweet?.id == tweet.id }
        }
    }
    
    static func fetchReplies(for tweetId: Int) async throws -> [Tweet] {
        return try await TWScrapeClient.shared.fetchReplies(for: tweetId)
    }
    
    static func searchTweets(query: String) async throws -> [Tweet] {
        let tweets = try await TWScrapeClient.shared.searchTweets(query: query)
        return filterTweets(tweets)
    }
    
    static func searchUsers(query: String) async throws -> [User] {
        return try await TWScrapeClient.shared.searchUsers(query: query)
    }
}
