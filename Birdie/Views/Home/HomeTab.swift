//
//  HomeTab.swift
//  Birdie
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct HomeTab: View {
    @State private var navManager = NavigationPathManager()

    var body: some View {
        NavigationStack(path: $navManager.path) {
            HomeView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .tweetDetail(let tweet):
                        TweetDetailView(tweet: tweet)
                    case .userDetail(let user):
                        UserDetailView(user: user)
                    }
                }
        }
        .environment(navManager)
    }
}

#Preview {
    HomeTab()
}
