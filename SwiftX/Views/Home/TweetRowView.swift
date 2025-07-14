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
            TweetView(tweet: tweet)
            
            Group {
                if let retweetedTweet = tweet.retweetedTweet {
                    TweetView(tweet: retweetedTweet)
                } else if let quotedTweet = tweet.quotedTweet {
                    TweetView(tweet: quotedTweet)
                }
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background.secondary)
            }
        }
    }
}
