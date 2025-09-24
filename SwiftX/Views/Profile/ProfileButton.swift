//
//  ProfileButton.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct ProfileButton: View {
    let user = User.zabir
    
    var body: some View {
        NavigationLink(destination: UserDetailView(user: user)) {
            Image(systemName: "person.fill")
        }
        .navigationLinkIndicatorVisibility(.hidden)
        
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
