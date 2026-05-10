//
//  HomeView.swift
//  Birdie
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var tweets: [Tweet] = []
    @State private var isLoading = false
    @State private var showingSettings = false
    @Bindable private var auth = XAuthStore.shared

    @Namespace private var transition

    var body: some View {
        List {
            TweetItemsView(tweets: tweets)
        }
        .listStyle(.plain)
        .task {
            guard auth.isAuthenticated, tweets.isEmpty else { return }
            await refresh(showProgress: true)
        }
        .refreshable {
            guard auth.isAuthenticated else { return }
            await refresh(showProgress: false)
        }
        .overlay {
            if !auth.isAuthenticated {
                ContentUnavailableView {
                    Label("Sign in to X", systemImage: "person.crop.circle.badge.exclamationmark")
                } description: {
                    Text("Birdie needs your X cookie and a list ID to load tweets. Add them in Settings → Authentication.")
                } actions: {
                    Button("Open Settings") {
                        showingSettings = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if isLoading {
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
            #if !os(macOS)
            .matchedTransitionSource(id: "settings-button", in: transition)
            #endif
            
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
            }
            #if !os(macOS)
            .navigationTransition(.zoom(sourceID: "settings-button", in: transition))
            #endif
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
