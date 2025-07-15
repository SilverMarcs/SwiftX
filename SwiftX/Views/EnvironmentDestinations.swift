//
//  EnvironmentDestinations.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

// First modifier for environments
struct EnvironmentActions: ViewModifier {
    @Binding var path: NavigationPath
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                // Check if the URL is a YouTube URL
                if isYouTubeURL(url) {
                    return .systemAction(prefersInApp: false) // Open in YouTube app
                }
                return .systemAction(prefersInApp: true) // Other URLs open in-app
            })
            .environment(\.appendToPath, { value in
                path.append(value)
            })
    }
    
    // Helper function to check if URL is from YouTube
    private func isYouTubeURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        return urlString.contains("youtube.com") || urlString.contains("youtu.be")
    }
}

// Second modifier for navigation destinations
struct NavigationDestinations: ViewModifier {
    @Binding var path: NavigationPath
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Tweet.self) { tweet in
                TweetDetailView(tweet: tweet)
                    .environmentActions(path: $path)
            }
            .navigationDestination(for: Retweet.self) { retweet in
                TweetDetailView(tweet: Tweet(from: retweet))
                    .environmentActions(path: $path)
            }
            .navigationDestination(for: User.self) { user in
                UserDetailView(user: user)
                    .environmentActions(path: $path)
            }
            .navigationDestination(for: ImageModalData.self) { data in
                ImageModal(data: data)
            }
    }
}

// Extension methods for easier usage
extension View {
    func environmentActions(path: Binding<NavigationPath>) -> some View {
        modifier(EnvironmentActions(path: path))
    }
    
    func navigationDestinations(path: Binding<NavigationPath>) -> some View {
        modifier(NavigationDestinations(path: path))
    }
}
