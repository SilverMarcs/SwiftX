//
//  UnifiedTweetView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI
import Kingfisher

struct TweetView: View {
    let tweet: Tweet
    @Environment(\.appendToPath) private var appendToPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            HStack {
                UserButton(user: tweet.user)
                Spacer()
                Text(tweet.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Dont shwo original tweet details if this is a repost/retweet
            if tweet.retweetedTweet == nil {
                Text(LocalizedStringKey(tweet.parsedContent))
                    .font(.default)
                    .opacity(0.9)
                
                ForEach(tweet.links, id: \.url) { url in
                    SwiftUI.Link(destination: URL(string: url.url)!) {
                        Label(url.text ?? "Link", systemImage: "link")
                    }
                }
                
                // Media Preview
                if let media = tweet.media {
                    MediaView(media: media)
                }
                
                // Engagement Stats
                HStack(spacing: 20) {
                    Label(tweet.formattedReplyCount, systemImage: "message")
                    
                    Label(tweet.formattedRetweetCount, systemImage: "arrow.2.squarepath")
                    
                    Label(tweet.formattedLikeCount, systemImage: "heart")
                    
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
            
            if let quotedTweet = tweet.quotedTweet {
                Button {
                    appendToPath(quotedTweet)
                } label: {
                   RetweetView(tweet: quotedTweet)
               }
               .buttonStyle(.plain)
           }
            
            if let retweet = tweet.retweetedTweet {
                Label("Retweeted", systemImage: "arrow.2.squarepath")
                    .labelStyle(RetweetLabel())
                    .labelIconToTitleSpacing(2)
                
                Button {
                    appendToPath(retweet)
                } label: {
                   RetweetView(tweet: retweet)
               }
               .buttonStyle(.plain)
           }
        }
        .contentShape(.rect)
    }
}

