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
                        
                        if tweet.user.blue == true {
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
                
                Text(formatDate(tweet.date))
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
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(tweet.retweetCount)", systemImage: "arrow.2.squarepath")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(tweet.likeCount)", systemImage: "heart")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if tweet.viewCount != nil {
                    Label("\(tweet.viewCount!)", systemImage: "eye")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let now = Date()
            let timeInterval = now.timeIntervalSince(date)
            
            if timeInterval < 60 {
                return "now"
            } else if timeInterval < 3600 {
                return "\(Int(timeInterval / 60))m"
            } else if timeInterval < 86400 {
                return "\(Int(timeInterval / 3600))h"
            } else {
                return "\(Int(timeInterval / 86400))d"
            }
        }
        return ""
    }
}

struct MediaView: View {
    let media: Media
    
    var body: some View {
        VStack {
            if let photos = media.photos, !photos.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(photos.indices, id: \.self) { index in
                            AsyncImage(url: URL(string: photos[index].url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(.gray.opacity(0.3))
                            }
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            
            if let videos = media.videos, !videos.isEmpty {
                ForEach(videos.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: videos[index].thumbnailUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            )
                    }
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
