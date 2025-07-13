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
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let url = URL(string: "\(baseURL)/tweets")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                await MainActor.run {
                    errorMessage = "Failed to fetch tweets"
                    isLoading = false
                }
                return
            }
            
            let decoder = JSONDecoder()
            let tweetResponse = try decoder.decode(TweetResponse.self, from: data)
            
            await MainActor.run {
                tweets = tweetResponse.tweets
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}
