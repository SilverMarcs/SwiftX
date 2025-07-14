//
//  CommonNavigationModifier.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

// Custom ViewModifier to handle common navigation settings
struct EnvironmentDestinations: ViewModifier {
    @Binding var path: NavigationPath
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                return .systemAction(prefersInApp: true)
            })
            .environment(\.appendToPath, { value in
                path.append(value)
            })
            .navigationDestination(for: Tweet.self) { tweet in
                TweetDetailView(tweet: tweet)
                    .environmentDestinations(path: $path)
            }
            .navigationDestination(for: ImageModalData.self) { data in
                ImageModal(data: data)
            }
    }
}

// View extension to make it easier to use the modifier
extension View {
    func environmentDestinations(path: Binding<NavigationPath>) -> some View {
        modifier(EnvironmentDestinations(path: path))
    }
}
