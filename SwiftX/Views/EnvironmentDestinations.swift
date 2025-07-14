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
                return .systemAction(prefersInApp: true)
            })
            .environment(\.appendToPath, { value in
                path.append(value)
            })
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
