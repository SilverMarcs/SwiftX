//
//  TweetService+Sample.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import Foundation

extension TweetService {
    static func loadSampleTweets() -> [Tweet] {
        return[
            Tweet(
                id: 1,
                url: "https://twitter.com/user1/status/1",
                date: "2025-07-13T12:00:00Z",
                user: User(
                    id: 101,
                    url: "https://twitter.com/user1",
                    username: "techEnthusiast",
                    displayname: "Tech Explorer",
                    rawDescription: "Exploring the frontiers of technology | AI & ML Enthusiast | Building the future",
                    created: "2020-01-01T00:00:00Z",
                    followersCount: 12400,
                    friendsCount: 850,
                    statusesCount: 3200,
                    location: "Silicon Valley",
                    profileImageUrl: "https://picsum.photos/seed/user1/200/200",
                    profileBannerUrl: "https://picsum.photos/seed/banner1/1500/500",
                    verified: true,
                    blue: true,
                    descriptionLinks: [],
                    pinnedIds: []
                ),
                rawContent: "Just launched our newest AI project! After months of hard work, we're excited to share this breakthrough in machine learning. Check out the demo below! 🎉🤖 #AI #Innovation #TechNews",
                replyCount: 245,
                retweetCount: 1893,
                likeCount: 7250,
                quoteCount: 89,
                conversationId: 1,
                conversationIdStr: "1",
                hashtags: ["AI", "Innovation", "TechNews"],
                mentionedUsers: [],
                links: [],
                media: Media(
                    photos: [Photo(url: "https://picsum.photos/seed/tweet1/800/600")],
                    videos: nil,
                    animated: nil
                ),
                viewCount: 52400,
                place: nil,
                inReplyToTweetId: nil,
                inReplyToTweetIdStr: nil,
                inReplyToUser: nil,
                source: "SwiftX",
                sourceUrl: nil,
                sourceLabel: nil,
                card: nil
            ),
            Tweet(
                id: 2,
                url: "https://twitter.com/user2/status/2",
                date: "2025-07-13T12:01:00Z",
                user: User(
                    id: 102,
                    url: "https://twitter.com/user2",
                    username: "naturePhotographer",
                    displayname: "Wild Earth",
                    rawDescription: "Capturing Earth's beauty one frame at a time | National Geographic Contributor",
                    created: "2021-02-02T00:00:00Z",
                    followersCount: 45200,
                    friendsCount: 1260,
                    statusesCount: 8900,
                    location: "Worldwide",
                    profileImageUrl: "https://picsum.photos/seed/user2/200/200",
                    profileBannerUrl: "https://picsum.photos/seed/banner2/1500/500",
                    verified: true,
                    blue: true,
                    descriptionLinks: [],
                    pinnedIds: []
                ),
                rawContent: "Sunrise at the Serengeti. Witnessed this magnificent lion pride during their morning hunt. Nature never ceases to amaze! 🦁 \n\nShot on Sony A7IV\n#Wildlife #Photography #Nature",
                replyCount: 892,
                retweetCount: 3241,
                likeCount: 15800,
                quoteCount: 142,
                conversationId: 2,
                conversationIdStr: "2",
                hashtags: ["Wildlife", "Photography", "Nature"],
                mentionedUsers: [],
                links: [],
                media: Media(
                    photos: [
                        Photo(url: "https://picsum.photos/seed/tweet2a/1200/800"),
                        Photo(url: "https://picsum.photos/seed/tweet2b/1200/800"),
                        Photo(url: "https://picsum.photos/seed/tweet2c/1200/800")
                    ],
                    videos: nil,
                    animated: nil
                ),
                viewCount: 89300,
                place: Place(
                    id: "123",
                    fullName: "Serengeti National Park, Tanzania",
                    name: "Serengeti",
                    type: "National Park",
                    country: "Tanzania",
                    countryCode: "TZ"
                ),
                inReplyToTweetId: nil,
                inReplyToTweetIdStr: nil,
                inReplyToUser: nil,
                source: "SwiftX Pro",
                sourceUrl: nil,
                sourceLabel: nil,
                card: nil
            ),
            Tweet(
                id: 3,
                url: "https://twitter.com/user3/status/3",
                date: "2025-07-13T12:02:00Z",
                user: User(
                    id: 103,
                    url: "https://twitter.com/user3",
                    username: "foodieCritic",
                    displayname: "Culinary Adventures",
                    rawDescription: "Food critic | Recipe developer | Cookbook author",
                    created: "2022-03-03T00:00:00Z",
                    followersCount: 28900,
                    friendsCount: 1470,
                    statusesCount: 5600,
                    location: "New York, NY",
                    profileImageUrl: "https://picsum.photos/seed/user3/200/200",
                    profileBannerUrl: "https://picsum.photos/seed/banner3/1500/500",
                    verified: false,
                    blue: true,
                    descriptionLinks: [],
                    pinnedIds: []
                ),
                rawContent: "NEW RECIPE ALERT! 🔥\n\nMy twist on traditional carbonara - featuring house-made pancetta and farm-fresh eggs. Full recipe in thread below! 🍝\n\n#Cooking #Foodie #ItalianCuisine",
                replyCount: 156,
                retweetCount: 742,
                likeCount: 3890,
                quoteCount: 67,
                conversationId: 3,
                conversationIdStr: "3",
                hashtags: ["Cooking", "FoodieLife", "ItalianCuisine"],
                mentionedUsers: [],
                links: [
                    Link(
                        url: "https://cooking.example.com/carbonara-recipe",
                        text: "Full Recipe Here",
                        tcourl: "https://t.co/abc123"
                    )
                ],
                media: Media(
                    photos: [Photo(url: "https://picsum.photos/seed/tweet3/1000/1000")],
                    videos: nil,
                    animated: nil
                ),
                viewCount: 28700,
                place: nil,
                inReplyToTweetId: nil,
                inReplyToTweetIdStr: nil,
                inReplyToUser: nil,
                source: "SwiftX",
                sourceUrl: nil,
                sourceLabel: nil,
                card: nil
            ),
            Tweet(
                id: 4,
                url: "https://twitter.com/user4/status/4",
                date: "2025-07-13T12:03:00Z",
                user: User(
                    id: 104,
                    url: "https://twitter.com/user4",
                    username: "devGuru",
                    displayname: "Code Master",
                    rawDescription: "Senior iOS Developer | SwiftUI Enthusiast | Tech Writer",
                    created: "2023-04-04T00:00:00Z",
                    followersCount: 18500,
                    friendsCount: 580,
                    statusesCount: 4200,
                    location: "San Francisco",
                    profileImageUrl: "https://picsum.photos/seed/user4/200/200",
                    profileBannerUrl: nil,
                    verified: false,
                    blue: true,
                    descriptionLinks: [],
                    pinnedIds: []
                ),
                rawContent: "🎯 Quick SwiftUI Tip:\n\nUse the new iOS 17 ScrollView improvements for better performance!\n\nHere's a before/after comparison of the same list with 1000 items.\n\nNotice the smooth scrolling? 🚀\n\n#SwiftUI #iOSDev #Programming",
                replyCount: 234,
                retweetCount: 891,
                likeCount: 2456,
                quoteCount: 45,
                conversationId: 4,
                conversationIdStr: "4",
                hashtags: ["SwiftUI", "iOSDev", "Programming"],
                mentionedUsers: [],
                links: [],
                media: Media(
                    photos: nil,
                    videos: [
                        Video(
                            thumbnailUrl: "https://picsum.photos/seed/tweet4/640/360",
                            variants: [
                                VideoVariant(
                                    contentType: "video/mp4",
                                    bitrate: 832000,
                                    url: "https://example.com/video.mp4"
                                )
                            ],
                            duration: 45,
                            views: 12400
                        )
                    ],
                    animated: nil
                ),
                viewCount: 35600,
                place: nil,
                inReplyToTweetId: nil,
                inReplyToTweetIdStr: nil,
                inReplyToUser: nil,
                source: "SwiftX",
                sourceUrl: nil,
                sourceLabel: nil,
                card: nil
            ),
            Tweet(
                id: 5,
                url: "https://twitter.com/user5/status/5",
                date: "2025-07-13T12:04:00Z",
                user: User(
                    id: 105,
                    url: "https://twitter.com/user5",
                    username: "gamingPro",
                    displayname: "Game Master",
                    rawDescription: "Professional gamer | Twitch Partner | ESports Commentator",
                    created: "2024-05-05T00:00:00Z",
                    followersCount: 89400,
                    friendsCount: 890,
                    statusesCount: 12600,
                    location: "Los Angeles",
                    profileImageUrl: "https://picsum.photos/seed/user5/200/200",
                    profileBannerUrl: "https://picsum.photos/seed/banner5/1500/500",
                    verified: true,
                    blue: true,
                    descriptionLinks: [],
                    pinnedIds: []
                ),
                rawContent: "WORLD RECORD! 🏆\n\nJust beat the previous speedrun record in Elden Ring! Full run coming to YouTube soon!\n\nTime: 12:34.56\nPrevious record: 12:45.89\n\nCouldn't have done it without the amazing community! 🙏\n\n#Gaming #EldenRing #Speedrun",
                replyCount: 1567,
                retweetCount: 4532,
                likeCount: 18900,
                quoteCount: 234,
                conversationId: 5,
                conversationIdStr: "5",
                hashtags: ["Gaming", "EldenRing", "Speedrun"],
                mentionedUsers: [],
                links: [],
                media: Media(
                    photos: nil,
                    videos: nil,
                    animated: [
                        AnimatedMedia(
                            thumbnailUrl: "https://picsum.photos/seed/tweet5/480/270",
                            videoUrl: "https://example.com/celebration.gif"
                        )
                    ]
                ),
                viewCount: 156000,
                place: nil,
                inReplyToTweetId: nil,
                inReplyToTweetIdStr: nil,
                inReplyToUser: nil,
                source: "SwiftX",
                sourceUrl: nil,
                sourceLabel: nil,
                card: Card(
                    type: "summary_large_image",
                    title: "New World Record - Elden Ring Speedrun",
                    description: "Watch the full speedrun video and see how the record was broken!",
                    vanityUrl: "youtube.com",
                    url: "https://youtube.com/watch?v=abc123",
                    photo: Photo(url: "https://picsum.photos/seed/card5/1200/675"),
                    video: nil,
                    options: nil,
                    finished: nil
                )
            )
        ]
    }
}
