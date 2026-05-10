//
//  TweetDetailView.swift
//  Birdie
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct TweetDetailView: View {
    let tweet: Tweet
    @State private var replies: [Tweet] = []
    @State private var isLoading = false
    @Environment(NavigationPathManager.self) private var navManager

    var body: some View {
        List {
            TweetView(tweet: tweet)
                .listRowSeparator(.hidden, edges: .top)
                .listRowSeparator(.visible, edges: .bottom)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

            if isLoading {
                UniversalProgressView()
            } else if !replies.isEmpty {
                Text("Replies")
                    .font(.title2)
                    .fontWeight(.semibold)
//                    .padding(.vertical, 2)
                    .listRowSeparator(.hidden)
                
                ForEach(replies) { reply in
                    Button {
                        navManager.path.append(NavigationDestination.tweetDetail(reply))
                    } label: {
                        TweetView(tweet: reply)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Tweet")
        .toolbarTitleDisplayMode(.inline)
        .task {
            if replies.isEmpty {
                await loadReplies()
            }
        }
    }

    private func loadReplies() async {
        isLoading = true
        
        do {
            let fetched = try await TweetService.fetchReplies(for: tweet.id)
            withAnimation {
                replies = fetched
            }
        } catch {
            print("Failed to load replies.")
        }
        isLoading = false
    }
}
