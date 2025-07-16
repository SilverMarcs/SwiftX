//
//  RepliesResponse.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

struct RepliesResponse: Decodable {
    let tweetId: Int
    let repliesCount: Int
    let replies: [Tweet]
}

// MARK: - Main Tweet Response
struct TweetResponse: Codable {
    let totalTweets: Int
    let tweets: [Tweet]
}

struct RefreshResponse: Decodable {
    let message: String
    let status: String
    let note: String
}

struct UserSearchResponse: Decodable {
    let totalUsers: Int
    let users: [User]
}

enum NetworkError: Error {
    case invalidURL
    case badServerResponse
    case decodingError
}
