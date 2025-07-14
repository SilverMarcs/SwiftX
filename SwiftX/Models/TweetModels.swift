//
//  Link.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

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
