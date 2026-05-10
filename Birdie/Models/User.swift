//
//  User.swift
//  Birdie
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
}

// MARK: - MentionedUser
struct MentionedUser: Codable {
    let id: Int
    let username: String
    let displayname: String
}
