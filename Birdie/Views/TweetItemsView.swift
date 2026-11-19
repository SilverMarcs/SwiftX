//
//  TweetItemsView.swift
//  Birdie
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct TweetItemsView: View {
    let tweets: [Tweet]
    var onAppear: @MainActor (Tweet) -> Void = { _ in }
    @Environment(NavigationPathManager.self) private var navManager
    
    var body: some View {
        ForEach(tweets) { tweet in
            Button {
                navManager.path.append(NavigationDestination.tweetDetail(tweet))
            } label: {
                TweetView(tweet: tweet)
            }
            .buttonStyle(.plain)
            .onAppear { onAppear(tweet) }
            .listRowSeparator(.visible, edges: .bottom)
            .listRowSeparator(.hidden, edges: .top)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
    }
}
