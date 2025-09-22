//
//  TweetContentView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct TweetContentView: View {
    let tweet: any TweetContentProtocol
    var hideHeader: Bool = false
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            if !hideHeader {
                TweetHeader(tweet: tweet)
            }
            
            // Tweet Content
            Text(tweet.parsedContent)
                .font(.default)
                .opacity(0.9)
            
            ForEach(tweet.links, id: \.url) { url in
                Button {
                    openURL(URL(string: url.url)!)
                } label: {
                    Label(url.text ?? "Link", systemImage: "link")
                        .labelStyle(RetweetLabel())
                        .foregroundStyle(.blue)
                        .brightness(colorScheme == .dark ? 0.6 : 0)
                }
                .buttonStyle(.plain)
            }
            
            // Media Preview
            if let media = tweet.media {
                MediaView(media: media)
            }
            
            // Engagement Stats
            HStack(spacing: 20) {
                Group{
                    Label(tweet.formattedReplyCount, systemImage: "message")
                    
                    Label(tweet.formattedRetweetCount, systemImage: "arrow.2.squarepath")
                    
                    Label(tweet.formattedLikeCount, systemImage: "heart")
                }
                .lineLimit(1)
                
                Spacer()
                
                Menu {
                    SwiftUI.Link(destination: tweet.twitterWebUrl!) {
                        Label("Open in X", systemImage: "bird")
                    }
                    
                    ShareLink("Share", item: tweet.twitterWebUrl!)
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(10)
                }
                .glassEffect()
            }
            .labelStyle(CustomLabelStyle())
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(4)
        }
        .contentShape(.rect)
    }
}
