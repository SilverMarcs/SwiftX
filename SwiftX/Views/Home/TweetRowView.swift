//
//  TweetRowView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Kingfisher

struct TweetRowView: View {
    let tweet: Tweet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            UnifiedTweetView(tweet: tweet)
            
            Group {
                if let retweetedTweet = tweet.retweetedTweet {
                    UnifiedTweetView(tweet: retweetedTweet)
                } else if let quotedTweet = tweet.quotedTweet {
                    UnifiedTweetView(tweet: quotedTweet)
                }
            }
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background.secondary)
            }
        }
    }
}
