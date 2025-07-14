//
//  ProfileButton.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI
import Kingfisher

struct ProfileButton: View {
    let user = User.zabir
    @Environment(\.appendToPath) var appendToPath
    
    var body: some View {
        Button {
            appendToPath(user)
        } label: {
//            KFImage(URL(string: user.profileImageUrl))
//                .placeholder {
//                    Rectangle()
//                        .fill(.background.secondary)
//                }
//                .downsampling(size: CGSize(width: 400, height: 400))
//                .serialize(as: .JPEG)
//                .fade(duration: 0.1)
//                .resizable()
//                    .frame(width: 37, height: 37)
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(Circle())
            Image(systemName: "person.fill")
        }
        .tint(.accentColor)
    }
}

extension User {
    static let zabir = User(
        id: 766520415350960128,
        url: "https://x.com/SilverMarcs3",
        username: "SilverMarcs3",
        displayname: "Zabir Raihan",
        rawDescription: "Just a random tweeter",
        created: "2016-08-19 06:21:23+00:00",
        followersCount: 10,
        friendsCount: 146,
        statusesCount: 122,
        location: "",
        profileImageUrl: "https://pbs.twimg.com/profile_images/1230767334274416640/eqta4k7n_normal.jpg",
        profileBannerUrl: nil,
        verified: false,
        blue: false,
        descriptionLinks: [],
        pinnedIds: []
    )
}

extension User {
    init(id: Int, url: String, username: String, displayname: String,
         rawDescription: String, created: String, followersCount: Int,
         friendsCount: Int, statusesCount: Int, location: String?,
         profileImageUrl: String, profileBannerUrl: String?,
         verified: Bool?, blue: Bool?, descriptionLinks: [Link], pinnedIds: [Int]) {
        self.id = id
        self.url = url
        self.username = username
        self.displayname = displayname
        self.rawDescription = rawDescription
        self.created = created
        self.followersCount = followersCount
        self.friendsCount = friendsCount
        self.statusesCount = statusesCount
        self.location = location
        self.profileImageUrl = profileImageUrl
        self.profileBannerUrl = profileBannerUrl
        self.verified = verified
        self.blue = blue
        self.descriptionLinks = descriptionLinks
        self.pinnedIds = pinnedIds
        
        // Pre-compute formatted values
        self.formattedFollowersCount = "10"
        self.formattedFriendsCount = "146"
    }
}

#Preview {
    ProfileButton()
}
