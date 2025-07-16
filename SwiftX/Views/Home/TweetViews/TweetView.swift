//
//  UnifiedTweetView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct TweetView: View {
    let tweet: Tweet
    @Environment(\.appendToPath) private var appendToPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TweetHeader(tweet: tweet)
            
            if tweet.retweetedTweet == nil {
                TweetContentView(tweet: tweet, hideHeader: true)
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

