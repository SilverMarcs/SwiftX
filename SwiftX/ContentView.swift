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
                    VStack {
                        ProgressView()
                        Text("Loading tweets...")
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = tweetService.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await tweetService.fetchTweets()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if tweetService.tweets.isEmpty {
                    VStack {
                        Image(systemName: "bird")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No tweets yet")
                            .foregroundStyle(.secondary)
                        Text("Tap the refresh button to fetch tweets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List(tweetService.tweets) { tweet in
                        TweetRowView(tweet: tweet)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tweets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await tweetService.fetchTweets()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
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
