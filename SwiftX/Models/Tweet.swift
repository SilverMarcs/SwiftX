//
//  Tweet.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import Foundation

// MARK: - Tweet Protocol for unified view handling
protocol TweetDisplayable {
    var id: Int { get }
    var url: String { get }
    var date: String { get }
    var user: User { get }
    var rawContent: String { get }
    var replyCount: Int { get }
    var retweetCount: Int { get }
    var likeCount: Int { get }
    var quoteCount: Int { get }
    var media: Media? { get }
    var viewCount: Int? { get }
    var twitterWebUrl: URL? { get }
}

// MARK: - Tweet
struct Tweet2: Codable, Identifiable, TweetDisplayable {
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
//    var retweetedTweet: TweetReference? = nil
//    var quotedTweet: TweetReference? = nil
    let place: Place?
    let inReplyToTweetId: Int?
    let inReplyToTweetIdStr: String?
    let inReplyToUser: InReplyToUser?
    let source: String?
    let sourceUrl: String?
    let sourceLabel: String?
    let card: Card?
//    let possiblySensitive: Bool?
    
    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
}

struct Tweet: Hashable, Codable, Identifiable, TweetDisplayable {
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
    let retweetedTweet: Tweet2?
    let quotedTweet: Tweet2?
    let place: Place?
    let inReplyToTweetId: Int?
    let inReplyToTweetIdStr: String?
    let inReplyToUser: InReplyToUser?
    let source: String?
    let sourceUrl: String?
    let sourceLabel: String?
    let card: Card?
//    let possiblySensitive: Bool?
    
    var twitterWebUrl: URL? {
        return URL(string: "https://twitter.com/x/status/\(id)")
    }
    
    
}

// MARK: - User
struct User: Codable {
    let id: Int
    let url: String
    let username: String
    let displayname: String
    let rawDescription: String
    let created: String
    let followersCount: Int
    let friendsCount: Int
    let statusesCount: Int
    let location: String?
    let profileImageUrl: String
    let profileBannerUrl: String?
    let verified: Bool?
    let blue: Bool?
    let descriptionLinks: [Link]
    let pinnedIds: [Int]
}

// MARK: - MentionedUser
struct MentionedUser: Codable {
    let id: Int
    let username: String
    let displayname: String
}

// MARK: - Link
struct Link: Codable {
    let url: String
    let text: String?
    let tcourl: String?
}

// MARK: - Media
struct Media: Codable {
    let photos: [Photo]?
    let videos: [Video]?
    let animated: [AnimatedMedia]?
}

// MARK: - Photo
struct Photo: Codable {
    let url: String
}

// MARK: - Video
struct Video: Codable {
    let thumbnailUrl: String
    let variants: [VideoVariant]
    let duration: Int
    let views: Int?
}

// MARK: - VideoVariant
struct VideoVariant: Codable {
    let contentType: String
    let bitrate: Int?
    let url: String
}

// MARK: - AnimatedMedia
struct AnimatedMedia: Codable {
    let thumbnailUrl: String
    let videoUrl: String
}

// MARK: - Place
struct Place: Codable {
    let id: String
    let fullName: String
    let name: String
    let type: String
    let country: String
    let countryCode: String
}

// MARK: - InReplyToUser
struct InReplyToUser: Codable {
    let id: Int
    let username: String
    let displayname: String
}

// MARK: - Card
struct Card: Codable {
    let type: String?
    let title: String?
    let description: String?
    let vanityUrl: String?
    let url: String?
    let photo: Photo?
    let video: Video?
    let options: [PollOption]?
    let finished: Bool?
}

// MARK: - PollOption
struct PollOption: Codable {
    let label: String
    let votesCount: Int
}
