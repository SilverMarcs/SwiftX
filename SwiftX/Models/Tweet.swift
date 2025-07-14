//
//  Tweet.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import Foundation

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
    let date: String
    let user: User
    let rawContent: String
    let replyCount: Int
    let retweetCount: Int
    let likeCount: Int
    let quoteCount: Int
    let conversationId: Int
    let conversationIdStr: String
    let hashtags: [String]
    let mentionedUsers: [MentionedUser]
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
    let sourceLabel: String?
    let card: Card?
//    let possiblySensitive: Bool?
    
    // Pre-computed formatted values
    let formattedDate: String
    let formattedReplyCount: String
    let formattedRetweetCount: String
    let formattedLikeCount: String
    let formattedQuoteCount: String
    
    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all the original properties
        id = try container.decode(Int.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        date = try container.decode(String.self, forKey: .date)
        user = try container.decode(User.self, forKey: .user)
        rawContent = try container.decode(String.self, forKey: .rawContent)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        retweetCount = try container.decode(Int.self, forKey: .retweetCount)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        quoteCount = try container.decode(Int.self, forKey: .quoteCount)
        conversationId = try container.decode(Int.self, forKey: .conversationId)
        conversationIdStr = try container.decode(String.self, forKey: .conversationIdStr)
        hashtags = try container.decode([String].self, forKey: .hashtags)
        mentionedUsers = try container.decode([MentionedUser].self, forKey: .mentionedUsers)
        links = try container.decode([Link].self, forKey: .links)
        media = try container.decodeIfPresent(Media.self, forKey: .media)
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount)
        place = try container.decodeIfPresent(Place.self, forKey: .place)
        inReplyToTweetId = try container.decodeIfPresent(Int.self, forKey: .inReplyToTweetId)
        inReplyToTweetIdStr = try container.decodeIfPresent(String.self, forKey: .inReplyToTweetIdStr)
        inReplyToUser = try container.decodeIfPresent(InReplyToUser.self, forKey: .inReplyToUser)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        sourceLabel = try container.decodeIfPresent(String.self, forKey: .sourceLabel)
        card = try container.decodeIfPresent(Card.self, forKey: .card)
        
        // Pre-compute formatted values
        formattedDate = date.formattedRelativeDate()
        formattedReplyCount = replyCount.formattedCount()
        formattedRetweetCount = retweetCount.formattedCount()
        formattedLikeCount = likeCount.formattedCount()
        formattedQuoteCount = quoteCount.formattedCount()
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
    let date: String
    let user: User
    let rawContent: String
    let replyCount: Int
    let retweetCount: Int
    let likeCount: Int
    let quoteCount: Int
    let conversationId: Int
    let conversationIdStr: String
    let hashtags: [String]
    let mentionedUsers: [MentionedUser]
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
    let card: Card?
//    let possiblySensitive: Bool?
    
    // Pre-computed formatted values
    let formattedDate: String
    let formattedReplyCount: String
    let formattedRetweetCount: String
    let formattedLikeCount: String
    let formattedQuoteCount: String
    
    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all the original properties
        id = try container.decode(Int.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        date = try container.decode(String.self, forKey: .date)
        user = try container.decode(User.self, forKey: .user)
        rawContent = try container.decode(String.self, forKey: .rawContent)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        retweetCount = try container.decode(Int.self, forKey: .retweetCount)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        quoteCount = try container.decode(Int.self, forKey: .quoteCount)
        conversationId = try container.decode(Int.self, forKey: .conversationId)
        conversationIdStr = try container.decode(String.self, forKey: .conversationIdStr)
        hashtags = try container.decode([String].self, forKey: .hashtags)
        mentionedUsers = try container.decode([MentionedUser].self, forKey: .mentionedUsers)
        links = try container.decode([Link].self, forKey: .links)
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
        card = try container.decodeIfPresent(Card.self, forKey: .card)
        
        // Pre-compute formatted values
        formattedDate = date.formattedRelativeDate()
        formattedReplyCount = replyCount.formattedCount()
        formattedRetweetCount = retweetCount.formattedCount()
        formattedLikeCount = likeCount.formattedCount()
        formattedQuoteCount = quoteCount.formattedCount()
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
        self.mentionedUsers = retweet.mentionedUsers
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
        self.card = retweet.card
        
        // Pre-compute formatted values
        self.formattedDate = retweet.formattedDate
        self.formattedReplyCount = retweet.formattedReplyCount
        self.formattedRetweetCount = retweet.formattedRetweetCount
        self.formattedLikeCount = retweet.formattedLikeCount
        self.formattedQuoteCount = retweet.formattedQuoteCount
    }
}
