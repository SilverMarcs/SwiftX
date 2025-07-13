//
//  TweetService.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import Foundation

struct TweetService {
    static func fetchTweets() async throws -> [Tweet] {
        let baseURL = AppSettings.shared.useWebserver ? AppSettings.webserver : AppSettings.localhost
        let url = URL(string: "\(baseURL)/tweets")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(AppSettings.shared.apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        let tweetResponse = try decoder.decode(TweetResponse.self, from: data)
        return tweetResponse.tweets
    }
}
