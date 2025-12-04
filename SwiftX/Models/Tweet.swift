//
//  Tweet.swift
//  SwiftX
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
//    let mentionedUsers: [MentionedUser]
    let links: [Link]
    let media: Media?
    let viewCount: Int?
//    var retweetedTweet: Tweet? = nil
//    var quotedTweet: Tweet? = nil
    let place: Place?
    let inReplyToTweetId: Int?
    let inReplyToTweetIdStr: String?
    let inReplyToUser: InReplyToUser?
    let source: String?
    let sourceUrl: String?
    let sourceLabel: String? // Twitter Web App // Twitter for iPhone
//    let card: Card?
//    let possiblySensitive: Bool?

    var parsedContent: String {
        String.parseContent(rawContent)
    }

    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all the original properties
        id = try container.decode(Int.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        date = try container.decode(Date.self, forKey: .date)
        user = try container.decode(User.self, forKey: .user)
        rawContent = try container.decode(String.self, forKey: .rawContent)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        retweetCount = try container.decode(Int.self, forKey: .retweetCount)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        quoteCount = try container.decode(Int.self, forKey: .quoteCount)
        conversationId = try container.decode(Int.self, forKey: .conversationId)
        conversationIdStr = try container.decode(String.self, forKey: .conversationIdStr)
        hashtags = try container.decode([String].self, forKey: .hashtags)
        
        // Decode links and remove duplicates
        let decodedLinks = try container.decode([Link].self, forKey: .links)
        links = Array(Set(decodedLinks)) // Remove duplicates using Set
        
        media = try container.decodeIfPresent(Media.self, forKey: .media)
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount)
        place = try container.decodeIfPresent(Place.self, forKey: .place)
        inReplyToTweetId = try container.decodeIfPresent(Int.self, forKey: .inReplyToTweetId)
        inReplyToTweetIdStr = try container.decodeIfPresent(String.self, forKey: .inReplyToTweetIdStr)
        inReplyToUser = try container.decodeIfPresent(InReplyToUser.self, forKey: .inReplyToUser)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        sourceLabel = try container.decodeIfPresent(String.self, forKey: .sourceLabel)
        
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(date, forKey: .date)
        try container.encode(user, forKey: .user)
        try container.encode(rawContent, forKey: .rawContent)
        try container.encode(replyCount, forKey: .replyCount)
        try container.encode(retweetCount, forKey: .retweetCount)
        try container.encode(likeCount, forKey: .likeCount)
        try container.encode(quoteCount, forKey: .quoteCount)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(conversationIdStr, forKey: .conversationIdStr)
        try container.encode(hashtags, forKey: .hashtags)
        try container.encode(links, forKey: .links)
        try container.encodeIfPresent(media, forKey: .media)
        try container.encodeIfPresent(viewCount, forKey: .viewCount)
        try container.encodeIfPresent(place, forKey: .place)
        try container.encodeIfPresent(inReplyToTweetId, forKey: .inReplyToTweetId)
        try container.encodeIfPresent(inReplyToTweetIdStr, forKey: .inReplyToTweetIdStr)
        try container.encodeIfPresent(inReplyToUser, forKey: .inReplyToUser)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceUrl, forKey: .sourceUrl)
        try container.encodeIfPresent(sourceLabel, forKey: .sourceLabel)
    }

    private enum CodingKeys: String, CodingKey {
        case id, url, date, user, rawContent, replyCount, retweetCount, likeCount, quoteCount
        case conversationId, conversationIdStr, hashtags, links, media, viewCount
        case place, inReplyToTweetId, inReplyToTweetIdStr, inReplyToUser
        case source, sourceUrl, sourceLabel
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
//    let mentionedUsers: [MentionedUser]
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
//    let card: Card?
//    let possiblySensitive: Bool?

    var parsedContent: String {
        String.parseContent(rawContent)
    }

    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all the original properties
        id = try container.decode(Int.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        date = try container.decode(Date.self, forKey: .date)
        user = try container.decode(User.self, forKey: .user)
        rawContent = try container.decode(String.self, forKey: .rawContent)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        retweetCount = try container.decode(Int.self, forKey: .retweetCount)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        quoteCount = try container.decode(Int.self, forKey: .quoteCount)
        conversationId = try container.decode(Int.self, forKey: .conversationId)
        conversationIdStr = try container.decode(String.self, forKey: .conversationIdStr)
        hashtags = try container.decode([String].self, forKey: .hashtags)
        
        // Decode links and remove duplicates
        let decodedLinks = try container.decode([Link].self, forKey: .links)
        links = Array(Set(decodedLinks)) // Remove duplicates using Set
        
        media = try container.decodeIfPresent(Media.self, forKey: .media)
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount)
        retweetedTweet = try container.decodeIfPresent(Retweet.self, forKey: .retweetedTweet)
        quotedTweet = try container.decodeIfPresent(Retweet.self, forKey: .quotedTweet)
        place = try container.decodeIfPresent(Place.self, forKey: .place)
        inReplyToTweetId = try container.decodeIfPresent(Int.self, forKey: .inReplyToTweetId)
        inReplyToTweetIdStr = try container.decodeIfPresent(String.self, forKey: .inReplyToTweetIdStr)
        inReplyToUser = try container.decodeIfPresent(InReplyToUser.self, forKey: .inReplyToUser)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        sourceLabel = try container.decodeIfPresent(String.self, forKey: .sourceLabel)
        
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
//        self.mentionedUsers = retweet.mentionedUsers
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
//        self.card = retweet.card
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(date, forKey: .date)
        try container.encode(user, forKey: .user)
        try container.encode(rawContent, forKey: .rawContent)
        try container.encode(replyCount, forKey: .replyCount)
        try container.encode(retweetCount, forKey: .retweetCount)
        try container.encode(likeCount, forKey: .likeCount)
        try container.encode(quoteCount, forKey: .quoteCount)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(conversationIdStr, forKey: .conversationIdStr)
        try container.encode(hashtags, forKey: .hashtags)
        try container.encode(links, forKey: .links)
        try container.encodeIfPresent(media, forKey: .media)
        try container.encodeIfPresent(viewCount, forKey: .viewCount)
        try container.encodeIfPresent(retweetedTweet, forKey: .retweetedTweet)
        try container.encodeIfPresent(quotedTweet, forKey: .quotedTweet)
        try container.encodeIfPresent(place, forKey: .place)
        try container.encodeIfPresent(inReplyToTweetId, forKey: .inReplyToTweetId)
        try container.encodeIfPresent(inReplyToTweetIdStr, forKey: .inReplyToTweetIdStr)
        try container.encodeIfPresent(inReplyToUser, forKey: .inReplyToUser)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceUrl, forKey: .sourceUrl)
        try container.encodeIfPresent(sourceLabel, forKey: .sourceLabel)
    }

    private enum CodingKeys: String, CodingKey {
        case id, url, date, user, rawContent, replyCount, retweetCount, likeCount, quoteCount
        case conversationId, conversationIdStr, hashtags, links, media, viewCount
        case retweetedTweet, quotedTweet, place, inReplyToTweetId, inReplyToTweetIdStr
        case inReplyToUser, source, sourceUrl, sourceLabel
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
