//
//  TweetDetailView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct TweetDetailView: View {
    let tweet: Tweet
    @State private var replies: [Tweet] = []
    @State private var isLoading = false

    var body: some View {
        List {
            TweetRowView(tweet: tweet)
                .listRowSeparator(.hidden, edges: .top)
                .listRowSeparator(.visible, edges: .bottom)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
            } else if !replies.isEmpty {
                Text("Replies")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                    .listRowSeparator(.hidden)
                
                ForEach(replies) { reply in
                    TweetRowView(tweet: reply)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Tweet")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await loadReplies()
        }
    }

    private func loadReplies() async {
        isLoading = true
        
        do {
            let fetched = try await TweetService.fetchReplies(for: tweet.id)
            replies = fetched
        } catch {
            print("Failed to load replies.")
        }
        isLoading = false
    }
}
