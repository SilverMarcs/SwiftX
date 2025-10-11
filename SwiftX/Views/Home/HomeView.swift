//
//  HomeView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var tweets: [Tweet] = []
    @State private var isLoading = false

    var body: some View {
        List {
            TweetItemsView(tweets: tweets)
        }
        .overlay {
            if isLoading {
                UniversalProgressView()
            }
        }
        .listStyle(.plain)
        .task {
            guard tweets.isEmpty else { return }
            isLoading = true
            await fetchTweets()
            isLoading = false
        }
        .refreshable {
            await fetchTweets()
        }
        .navigationTitle("Tweets")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem {
                ProfileButton()
            }
//            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    
    private func fetchTweets() async {
        do {
            let fetched = try await TweetService.fetchTweets()
            tweets = fetched
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    HomeView()
}
