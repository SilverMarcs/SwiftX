//
//  ContentView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var tweetService = TweetService()
    
    var body: some View {
        NavigationStack {
            Group {
                if tweetService.isLoading {
                    ProgressView()
                } else if let errorMessage = tweetService.errorMessage {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    }
                } else if tweetService.tweets.isEmpty {
                    ContentUnavailableView {
                        Label("No tweets yet", systemImage: "bird.fill")
                    } description: {
                        Text("Tap the refresh button to fetch tweets")
                    }
                } else {
                    List(tweetService.tweets) { tweet in
                        TweetRowView(tweet: tweet)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        Task {
                            await tweetService.fetchTweets()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(tweetService.isLoading)
                    
                    Button {
                        tweetService.loadSampleTweets()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .disabled(tweetService.isLoading)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
