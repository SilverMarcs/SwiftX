//
//  TweetRowView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct TweetRowView: View {
    let tweet: Tweet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            HStack {
                AsyncImage(url: URL(string: tweet.user.profileImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.background.secondary)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(tweet.user.displayname)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if tweet.user.verified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.caption)
                        } else if tweet.user.blue == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.yellow)
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
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(5)
            
            if let retweetedTweet = tweet.retweetedTweet {
                RetweetedTweetView(tweet: retweetedTweet)
                    .padding(15)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.background.secondary)
                    }
            }
        }
    }
}
