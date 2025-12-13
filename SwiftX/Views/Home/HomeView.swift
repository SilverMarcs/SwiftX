//
//  HomeView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var tweets: [Tweet] = []
    @State private var isLoadingMore = false
    @State private var nextCursor: String?
    @State private var showingSettings = false
    
    @Namespace private var transition

    var body: some View {
        List {
            TweetItemsView(tweets: tweets)

            if nextCursor != nil {
                Color.clear
                    .frame(height: 1)
                    .listRowSeparator(.hidden)
                    .onAppear {
                        Task { await loadMore() }
                    }
            }

            if isLoadingMore {
                UniversalProgressView()
                    .id(UUID())
            }
        }
        .listStyle(.plain)
        .task {
            guard tweets.isEmpty else { return }
            await refresh(showProgress: true)
        }
        .refreshable {
            await refresh(showProgress: false)
        }
        .navigationTitle("Tweets")
        .toolbarTitleDisplayMode(.inlineLarge)
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
        nextCursor = nil
        if showProgress { tweets = [] }
        await loadMore(reset: true, showProgress: showProgress)
    }
    
    private func loadMore(reset: Bool = false, showProgress: Bool = true) async {
        // Only guard on isLoadingMore if we're actually using it
        guard !isLoadingMore else { return }
        if !reset, nextCursor == nil { return }

        if showProgress {
            isLoadingMore = true
        }
        defer {
            if showProgress {
                isLoadingMore = false
            }
        }

        do {
            let result = try await TweetService.fetchTimelinePage(
                cursor: reset ? nil : nextCursor,
                pageSize: 20
            )
            nextCursor = result.nextCursor

            var existing = Set(tweets.map { $0.id })
            let fresh = result.tweets.filter { !existing.contains($0.id) }
            existing.formUnion(fresh.map { $0.id })
            tweets.append(contentsOf: fresh)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    HomeView()
}
