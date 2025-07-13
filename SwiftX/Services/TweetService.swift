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
        return response.tweets
    }
}

enum NetworkError: Error {
    case invalidURL
    case badServerResponse
    case decodingError
}

struct RefreshResponse: Decodable {
    let message: String
    let status: String
    let note: String
}
