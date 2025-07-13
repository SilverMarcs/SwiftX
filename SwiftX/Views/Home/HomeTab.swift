//
//  HomeTab.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct HomeTab: View {
    @State private var tweets: [Tweet] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let errorMessage {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    }
                } else if tweets.isEmpty {
                    ContentUnavailableView {
                        Label("No tweets yet", systemImage: "bird.fill")
                    } description: {
                        Text("Tap the refresh button to fetch tweets")
                    }
                } else {
                    List(tweets) { tweet in
                        TweetRowView(tweet: tweet)
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
                            await fetchTweets()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)

                    Button {
                        loadSampleTweets()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .disabled(isLoading)
                }
            }
        }
    }

    private func fetchTweets() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetched = try await TweetService.fetchTweets()
            tweets = fetched
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }

    private func loadSampleTweets() {
        tweets = TweetService.loadSampleTweets()
        errorMessage = nil
    }
}

#Preview {
    HomeTab()
}
