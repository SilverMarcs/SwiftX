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
    @State private var errorMessage: String?

    var body: some View {
        List {
            TweetView(tweet: tweet)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden, edges: .top)
                .listRowSeparator(.visible, edges: .bottom)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

            if isLoading {
                UniversalProgressView()
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
            } else if let errorMessage {
                FeedRetryRow(message: errorMessage) { await loadReplies() }
            } else if !replies.isEmpty {
                Text("Replies")
                    .font(.title2)
                    .bold()
//                    .padding(.vertical, 2)
                    .frame(maxWidth: 800, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                
                TweetItemsView(tweets: replies)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Post")
        .toolbarTitleDisplayMode(.inline)
        .task {
            if replies.isEmpty {
                await loadReplies()
            }
        }
    }

    private func loadReplies() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetched = try await XClient.shared.fetchReplies(tweetID: tweet.id)
            try Task.checkCancellation()
            withAnimation {
                replies = fetched
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }
}
