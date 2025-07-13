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
        VStack(alignment: .leading, spacing: 8) {
            // User Info
            HStack {
                AsyncImage(url: URL(string: tweet.user.profileImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.gray.opacity(0.3))
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
                        }
                    }
                    
                    Text("@\(tweet.user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(tweet.date.formatDate())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Tweet Content
            Text(tweet.rawContent)
                .font(.body)
            
            // Media Preview
            if let media = tweet.media {
                MediaView(media: media)
            }
            
            // Engagement Stats
            HStack(spacing: 20) {
                Label("\(tweet.replyCount)", systemImage: "bubble.left")
                
                Label("\(tweet.retweetCount)", systemImage: "arrow.2.squarepath")
                
                Label("\(tweet.likeCount)", systemImage: "heart")
                
                Label("\(tweet.viewCount ?? 0)", systemImage: "eye")
                
                Spacer()
                
                // three dot contetx menu here maybe
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(5)
        }
    }
}
