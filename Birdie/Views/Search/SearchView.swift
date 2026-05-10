//
//  SearchView.swift
//  Birdie
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var isLoading = false
    @Environment(NavigationPathManager.self) private var navManager
    
    @State private var searchText = ""
    @State private var searchScope: SearchScope = .tweets
    
    @State private var tweetResults: [Tweet] = []
    @State private var userResults: [User] = []
    
    private var hasResults: Bool {
        !tweetResults.isEmpty || !userResults.isEmpty
    }
    
    var body: some View {
        Group {
            switch searchScope {
            case .tweets:
                List {
                    TweetItemsView(tweets: tweetResults)
                }
                .listStyle(.plain)
            case .users:
                List {
                    ForEach(userResults, id: \.id) { user in
                        Button {
                            navManager.path.append(NavigationDestination.userDetail(user))
                        } label: {
                            HStack {
                                UserHeader(user: user)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary.opacity(0.6))
                                    .font(.system(size: 13.5, weight: .medium))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                UniversalProgressView()
            }
        }
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inlineLarge)
        .searchable(text: $searchText, placement: .toolbarPrincipal, prompt: "Search \(searchScope.rawValue)")
        .searchScopes($searchScope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .onSubmit(of: .search) {
            Task {
                await performSearch()
            }
        }
        .onChange(of: searchScope) {
            clearResults()
            Task {
                await performSearch()
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    searchText = ""
                    clearResults()
                } label: {
                    Image(systemName: "eraser")
                }
                .disabled(searchText.isEmpty && !hasResults)
            }
        }
    }
    
    private func clearResults() {
        tweetResults = []
        userResults = []
    }
    
    private func performSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearResults()
            return
        }
        
        isLoading = true
        
        do {
            switch searchScope {
            case .tweets:
                userResults = []
                tweetResults = try await TweetService.searchTweets(query: searchText)
            case .users:
                tweetResults = []
                userResults = try await TweetService.searchUsers(query: searchText)
            }
        } catch {
            clearResults()
        }
        
        isLoading = false
    }
}

enum SearchScope: String, CaseIterable {
    case tweets = "Tweets"
    case users = "Users"
}
