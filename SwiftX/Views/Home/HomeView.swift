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
    @State private var showingSettings = false
    
    @Namespace private var transition

    var body: some View {
        List {
            TweetItemsView(tweets: tweets)
        }
        .listStyle(.plain)
        .task {
            guard tweets.isEmpty else { return }
            await refresh(showProgress: true)
        }
        .refreshable {
            await refresh(showProgress: false)
        }
        .overlay {
            if isLoading {
                UniversalProgressView()
            }
        }
        .navigationTitle("Home")
        .toolbarTitleDisplayMode(.inlineLarge)
        .navigationSubtitle("\(tweets.count) tweets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
            .matchedTransitionSource(id: "settings-button", in: transition)
            
//            ToolbarItem {
////                ProfileButton()
//                Button {
//                    
//                } label: {
//                    Text("\(tweets.count)")
//                        .foregroundStyle(.link)
//                }
//                .buttonBorderShape(.circle)
//            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .presentationDetents([.medium])
            }
            .navigationTransition(.zoom(sourceID: "settings-button", in: transition))
        }
    }
    
    
    private func refresh(showProgress: Bool) async {
        if showProgress {
            isLoading = true
        }
        defer {
            if showProgress {
                isLoading = false
            }
        }

        do {
            let freshTweets = try await TweetService.fetchTweets()
            withAnimation {
                tweets = freshTweets
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    HomeView()
}
