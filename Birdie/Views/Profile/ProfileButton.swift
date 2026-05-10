//
//  ProfileButton.swift
//  Birdie
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct ProfileButton: View {
    let user = User.zabir
    @Environment(NavigationPathManager.self) private var navManager
    
    var body: some View {
        Button {
            navManager.path.append(NavigationDestination.userDetail(user))
        } label: {
            Image(systemName: "person.fill")
        }
        .buttonStyle(.plain)
        
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
        created: Date(),
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

#Preview {
    ProfileButton()
}
