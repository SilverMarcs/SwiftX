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
                        .controlSize(.large)
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
                            .listRowSeparator(.visible, edges: .bottom)
                            .listRowSeparator(.hidden, edges: .top)
                    }
                    .listStyle(.plain)
                }
            }
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
//            .toolbar {
//              ProfleButton()
//            }
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
}

#Preview {
    HomeTab()
}
