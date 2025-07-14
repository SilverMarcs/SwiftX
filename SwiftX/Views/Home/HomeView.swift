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
    @State private var errorMessage: String? = nil
    
    @Environment(\.appendToPath) private var appendToPath

    var body: some View {
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
                    Button {
                        appendToPath(tweet)
                    } label: {
                        TweetRowView(tweet: tweet)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.visible, edges: .bottom)
                    .listRowSeparator(.hidden, edges: .top)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
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
//        .toolbar {
//            ProfileButton()
//        }
    }
    
    
    private func fetchTweets() async {
        errorMessage = nil
        isLoading = true
        
        do {
            let fetched = try await TweetService.fetchTweets()
            tweets = fetched
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    HomeView()
}
