//
//  TweetItemsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct TweetItemsView: View {
    let tweets: [Tweet]
    @Environment(\.appendToPath) private var appendToPath
    
    var body: some View {
        ForEach(tweets) { tweet in
            Button {
                appendToPath(tweet)
            } label: {
                TweetView(tweet: tweet)
            }
            .buttonStyle(.plain)
            .listRowSeparator(.visible, edges: .bottom)
            .listRowSeparator(.hidden, edges: .top)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
    }
}
