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
    
    @Environment(\.appendToPath) private var appendToPath

    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(tweets) { tweet in
                    Button {
                        appendToPath(tweet)
                    } label: {
                        TweetView(tweet: tweet)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.visible, edges: .bottom)
                    .listRowSeparator(.hidden, edges: .top)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                }
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
