//
//  UnifiedTweetView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct TweetView: View {
    let tweet: Tweet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TweetHeader(tweet: tweet)
            
            if tweet.retweetedTweet == nil {
                TweetContentView(tweet: tweet, hideHeader: true)
            }
            
            if let quotedTweet = tweet.quotedTweet {
                NavigationLink(destination: TweetDetailView(tweet: Tweet(from: quotedTweet))) {
                   RetweetView(tweet: quotedTweet)
               }
                .navigationLinkIndicatorVisibility(.hidden)
           }
            
            if let retweet = tweet.retweetedTweet {
                Label("Retweeted", systemImage: "arrow.2.squarepath")
                    .labelStyle(RetweetLabel())
                
                NavigationLink(destination: TweetDetailView(tweet: Tweet(from: retweet))) {
                   RetweetView(tweet: retweet)
               }
                .navigationLinkIndicatorVisibility(.hidden)
           }
        }
        .contentShape(.rect)
    }
}

