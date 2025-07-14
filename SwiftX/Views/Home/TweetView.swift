//
//  UnifiedTweetView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI
import Kingfisher

struct TweetView: View {
    let tweet: any TweetDisplayable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            HStack {
                UserButton(user: tweet.user)
                Spacer()
                Text(tweet.date.formatDate())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Tweet Content
            Text(LocalizedStringKey(tweet.rawContent))
                .font(.default)
                .opacity(0.9)
            
            // Media Preview
            if let media = tweet.media {
                MediaView(media: media)
            }
            
            // Engagement Stats
            HStack(spacing: 20) {
                Label("\(tweet.replyCount.formatCount)", systemImage: "message")
                
                Label("\(tweet.retweetCount.formatCount)", systemImage: "arrow.2.squarepath")
                
                Label("\(tweet.likeCount.formatCount)", systemImage: "heart")
                
                Spacer()
                
                Menu {
                    SwiftUI.Link(destination: tweet.twitterWebUrl!) {
                        Label("Open in X", systemImage: "bird")
                    }
                        
                    ShareLink("Share URL", item: tweet.twitterWebUrl!)
                } label: {
                    Image(systemName: "ellipsis")
                }
                .padding(10)
                .glassEffect()
            }
            .labelStyle(CustomLabelStyle())
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(4)
        }
    }
}
