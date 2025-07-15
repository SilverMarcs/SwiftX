//  TweetService.swift
//  SwiftX
//

import Foundation

struct TweetService {
    private static func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        let baseURL = AppSettings.shared.useWebserver ? AppSettings.webserver : AppSettings.localhost
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(AppSettings.shared.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badServerResponse
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    @discardableResult
    static func refreshTweetCache() async throws -> RefreshResponse {
        return try await makeRequest(
            endpoint: "tweets/refresh",
            method: "POST"
        )
    }
    
    static func fetchTweets() async throws -> [Tweet] {
        let response: TweetResponse = try await makeRequest(endpoint: "tweets")
        
        // Filter tweets to only include:
        // 1. Top-level tweets (not replies)
        // 2. Tweets that aren't quoted by other tweets
        // 3. Tweets that aren't retweeted by other tweets
        let filteredTweets = response.tweets.filter { tweet in
            // Check if:
            // - it's not a reply AND
            // - not quoted in any other tweet AND
            // - not retweeted in any other tweet
            tweet.inReplyToTweetId == nil &&
            !response.tweets.contains { $0.quotedTweet?.id == tweet.id } &&
            !response.tweets.contains { $0.retweetedTweet?.id == tweet.id }
        }
        
        return filteredTweets
    }
    
    static func fetchReplies(for tweetId: Int) async throws -> [Tweet] {
        let response: RepliesResponse = try await makeRequest(endpoint: "replies/\(tweetId)")
        return response.replies
    }
}
