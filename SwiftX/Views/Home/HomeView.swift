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
            
            if isLoading {
                UniversalProgressView()
            }
        }
        .listStyle(.plain)
        .task {
            if tweets.isEmpty {
                await fetchTweets()
            }
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
        isLoading = true
        
        do {
            let fetched = try await TweetService.fetchTweets()
            tweets = fetched
        } catch {
            print(error.localizedDescription)
        }
        
        isLoading = false
    }
}

#Preview {
    HomeView()
}
