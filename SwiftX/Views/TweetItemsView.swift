//
//  TweetItemsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct TweetItemsView: View {
    let tweets: [Tweet]
    
    var body: some View {
        ForEach(tweets) { tweet in
            NavigationLink(destination: TweetDetailView(tweet: tweet)) {
                TweetView(tweet: tweet)
            }
            .navigationLinkIndicatorVisibility(.hidden)
            .listRowSeparator(.visible, edges: .bottom)
            .listRowSeparator(.hidden, edges: .top)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
    }
}
