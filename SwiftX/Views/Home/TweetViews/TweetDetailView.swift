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

    @Environment(\.appendToPath) var appendToPath
    
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
                        appendToPath(reply)
                    } label: {
                        TweetView(tweet: reply)
                    }
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
