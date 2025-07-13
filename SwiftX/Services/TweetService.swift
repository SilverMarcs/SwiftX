//
//  TweetService.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import Foundation

@Observable
class TweetService {
    @ObservationIgnored private let baseURL = "http://192.168.0.154:8000"
    
    var tweets: [Tweet] = []
    var isLoading = false
    var errorMessage: String?
    
    func fetchTweets() async {
        errorMessage = nil
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let url = URL(string: "\(baseURL)/tweets")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch tweets"
                return
            }
            
            let decoder = JSONDecoder()
            let tweetResponse = try decoder.decode(TweetResponse.self, from: data)
            
            tweets = tweetResponse.tweets
            
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
}
