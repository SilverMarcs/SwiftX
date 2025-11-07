//
//  SearchTab.swift
//  SwiftX
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct SearchTab: View {
    @State private var navManager = NavigationPathManager()
    var body: some View {
        NavigationStack(path: $navManager.path) {
            SearchView()
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
