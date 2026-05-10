//
//  Tweet.swift
//  Birdie
//
//  Created by Zabir Raihan on 13/07/2025.
//

import Foundation

enum TweetDateParser {
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let isoFractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let fallbackFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return formatter
    }()

    static let twitterFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter
    }()

    static func parse(_ value: String) -> Date? {
        if let date = isoFractionalFormatter.date(from: value) { return date }
        if let date = isoFormatter.date(from: value) { return date }
        if let date = fallbackFormatter.date(from: value) { return date }
        if let date = twitterFormatter.date(from: value) { return date }
        return nil
    }

}

// MARK: - Tweet
struct Retweet: Codable, Hashable, Identifiable {
    static func == (lhs: Retweet, rhs: Retweet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let url: String
    let date: Date
    let user: User
    let rawContent: String
    let replyCount: Int
    let retweetCount: Int
    let likeCount: Int
    let quoteCount: Int
    let conversationId: Int
    let conversationIdStr: String
    let hashtags: [String]
    let links: [Link]
    let media: Media?
    let viewCount: Int?
    let place: Place?
    let inReplyToTweetId: Int?
    let inReplyToTweetIdStr: String?
    let inReplyToUser: InReplyToUser?
    let source: String?
    let sourceUrl: String?
    let sourceLabel: String? // Twitter Web App // Twitter for iPhone

    var parsedContent: String {
        String.parseContent(rawContent)
    }

    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
}

struct Tweet: Hashable, Codable, Identifiable {
    static func == (lhs: Tweet, rhs: Tweet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let url: String
    let date: Date
    let user: User
    let rawContent: String
    let replyCount: Int
    let retweetCount: Int
    let likeCount: Int
    let quoteCount: Int
    let conversationId: Int
    let conversationIdStr: String
    let hashtags: [String]
    let links: [Link]
    let media: Media?
    let viewCount: Int?
    let retweetedTweet: Retweet?
    let quotedTweet: Retweet?
    let place: Place?
    let inReplyToTweetId: Int?
    let inReplyToTweetIdStr: String?
    let inReplyToUser: InReplyToUser?
    let source: String?
    let sourceUrl: String?
    let sourceLabel: String?

    var parsedContent: String {
        String.parseContent(rawContent)
    }

    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
    
    init(from retweet: Retweet) {
        self.id = retweet.id
        self.url = retweet.url
        self.date = retweet.date
        self.user = retweet.user
        self.rawContent = retweet.rawContent
        self.replyCount = retweet.replyCount
        self.retweetCount = retweet.retweetCount
        self.likeCount = retweet.likeCount
        self.quoteCount = retweet.quoteCount
        self.conversationId = retweet.conversationId
        self.conversationIdStr = retweet.conversationIdStr
        self.hashtags = retweet.hashtags
        self.links = retweet.links
        self.media = retweet.media
        self.viewCount = retweet.viewCount
        self.retweetedTweet = nil  // Since Retweet doesn't have these properties
        self.quotedTweet = nil     // Since Retweet doesn't have these properties
        self.place = retweet.place
        self.inReplyToTweetId = retweet.inReplyToTweetId
        self.inReplyToTweetIdStr = retweet.inReplyToTweetIdStr
        self.inReplyToUser = retweet.inReplyToUser
        self.source = retweet.source
        self.sourceUrl = retweet.sourceUrl
        self.sourceLabel = retweet.sourceLabel
    }
}

// Protocol to unify Tweet and Retweet data access
protocol TweetContentProtocol {
    var id: Int { get }
    var user: User { get }
    var date: Date { get }
    var rawContent: String { get }
    var parsedContent: String { get }
    var links: [Link] { get }
    var hashtags: [String] { get }
    var media: Media? { get }
    var replyCount: Int { get }
    var retweetCount: Int { get }
    var likeCount: Int { get }
    var twitterWebUrl: URL? { get }
}

extension TweetContentProtocol {
    var parsedContent: String {
        String.parseContent(rawContent)
    }
}
// Extend Tweet to conform to the protocol
extension Tweet: TweetContentProtocol {}

// Extend Retweet to conform to the protocol
extension Retweet: TweetContentProtocol {}
