//
//  UnifiedTweetView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI
import Kingfisher

struct UnifiedTweetView: View {
    let tweet: any TweetDisplayable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            HStack {
                KFImage(URL(string: tweet.user.profileImageUrl))
                    .placeholder {
                        Rectangle()
                            .fill(.background.secondary)
                    }
                    .downsampling(size: CGSize(width: 250, height: 250))
                    .serialize(as: .JPEG)
                    .fade(duration: 0.1)
                    .frame(width: 40, height: 40)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(tweet.user.displayname)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if tweet.user.verified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        } else if tweet.user.blue == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Text("@\(tweet.user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(tweet.date.formatDate())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Tweet Content
            Text(LocalizedStringKey(tweet.rawContent))
                .font(.default)
            
            // Media Preview
            if let media = tweet.media {
                MediaView(media: media)
            }
            
            // Engagement Stats
            HStack(spacing: 20) {
                Label("\(tweet.replyCount)", systemImage: "bubble.left")
                
                Label("\(tweet.retweetCount)", systemImage: "arrow.2.squarepath")
                
                Label("\(tweet.likeCount)", systemImage: "heart")
                
                Spacer()
                
                Menu {
                    SwiftUI.Link(destination: tweet.twitterWebUrl!) {
                        Label("Open in X", systemImage: "bird")
                    }
                        
                    ShareLink("Share URL", item: tweet.twitterWebUrl!)
                } label: {
                    Label("Meny", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(5)
        }
    }
}
