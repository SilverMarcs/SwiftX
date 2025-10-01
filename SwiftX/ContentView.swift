//
//  ContentView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Tweets", systemImage: "bird.fill") {
                HomeTab()
            }

            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            
            Tab(role: .search) {
                SearchTab()
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            // Check if the URL is a YouTube URL
            if isYouTubeURL(url) {
                return .systemAction(prefersInApp: false) // Open in YouTube app
            }
            return .systemAction(prefersInApp: true) // Other URLs open in-app
        })
        .tabViewStyle(.sidebarAdaptable)
//        #if !os(macOS)
//        .tabBarMinimizeBehavior(.onScrollDown)
//        #endif
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
