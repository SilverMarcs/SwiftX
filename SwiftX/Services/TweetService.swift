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
        let tweets = try await TWScrapeClient.shared.fetchListTimeline()
        return filterTweets(tweets)
    }

    static func fetchUserTweets(userId: Int) async throws -> [Tweet] {
        let response: TweetResponse = try await makeRequest(endpoint: "user/\(userId)/tweets")
        return filterTweets(response.tweets)
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
        let response: RepliesResponse = try await makeRequest(endpoint: "replies/\(tweetId)")
        return response.replies
    }
    
    static func searchTweets(query: String) async throws -> [Tweet] {
        guard !query.isEmpty else { return [] }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let response: TweetResponse = try await makeRequest(endpoint: "search/tweets?q=\(encodedQuery)")
        return filterTweets(response.tweets)
    }
    
    static func searchUsers(query: String) async throws -> [User] {
        guard !query.isEmpty else { return [] }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let response: UserSearchResponse = try await makeRequest(endpoint: "search/users?q=\(encodedQuery)")
        return response.users
    }
}
