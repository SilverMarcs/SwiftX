//
//  User.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

// MARK: - User
struct User: Codable, Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let url: String
    let username: String
    let displayname: String
    let rawDescription: String
    let created: Date
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
    
    // Pre-computed formatted values
    let formattedFollowersCount: String
    let formattedFriendsCount: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all the original properties
        id = try container.decode(Int.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        username = try container.decode(String.self, forKey: .username)
        displayname = try container.decode(String.self, forKey: .displayname)
        rawDescription = try container.decode(String.self, forKey: .rawDescription)
        if let date = try? container.decode(Date.self, forKey: .created) {
            created = date
        } else {
            let createdString = try container.decode(String.self, forKey: .created)
            created = TweetDateParser.parse(createdString) ?? Date()
        }
        followersCount = try container.decode(Int.self, forKey: .followersCount)
        friendsCount = try container.decode(Int.self, forKey: .friendsCount)
        statusesCount = try container.decode(Int.self, forKey: .statusesCount)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        profileImageUrl = try container.decode(String.self, forKey: .profileImageUrl)
        profileBannerUrl = try container.decodeIfPresent(String.self, forKey: .profileBannerUrl)
        verified = try container.decodeIfPresent(Bool.self, forKey: .verified)
        blue = try container.decodeIfPresent(Bool.self, forKey: .blue)
        descriptionLinks = try container.decode([Link].self, forKey: .descriptionLinks)
        pinnedIds = try container.decode([Int].self, forKey: .pinnedIds)
        
        // Pre-compute formatted values
        formattedFollowersCount = followersCount.formattedCount()
        formattedFriendsCount = friendsCount.formattedCount()
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, url, username, displayname, rawDescription, created
        case followersCount, friendsCount, statusesCount, location
        case profileImageUrl, profileBannerUrl, verified, blue
        case descriptionLinks, pinnedIds
    }
}

// MARK: - MentionedUser
struct MentionedUser: Codable {
    let id: Int
    let username: String
    let displayname: String
}
