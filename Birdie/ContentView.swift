//
//  ContentView.swift
//  Birdie
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Feed", systemImage: "bird") {
                HomeTab()
                    .id(XSessionStore.shared.revision)
            }

            Tab("Settings", systemImage: "gear") {
                NavigationStack {
                    SettingsView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchTab()
                    .id(XSessionStore.shared.revision)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        #if os(iOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
        .tabViewSearchActivation(.searchTabSelection)
        .environment(\.openURL, OpenURLAction { url in
            if isYouTubeURL(url) {
                return .systemAction(prefersInApp: false) // Open in YouTube app
            }
            return .systemAction(prefersInApp: true) // Other URLs open in-app
        })

    }
    // Helper function to check if URL is from YouTube
    private func isYouTubeURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        return urlString.contains("youtube.com") || urlString.contains("youtu.be")
    }
}

#Preview {
    ContentView()
}
