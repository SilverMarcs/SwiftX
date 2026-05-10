//
//  UnifiedTweetView.swift
//  Birdie
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct TweetView: View {
    let tweet: Tweet
    @Environment(NavigationPathManager.self) private var navManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TweetHeader(tweet: tweet)
            
            if tweet.retweetedTweet == nil {
                TweetContentView(tweet: tweet, hideHeader: true)
            }
            
            if let quotedTweet = tweet.quotedTweet {
                Button {
                    navManager.path.append(NavigationDestination.tweetDetail(Tweet(from: quotedTweet)))
                } label: {
                    RetweetView(tweet: quotedTweet)
                }
                .buttonStyle(.plain)
           }
            
            if let retweet = tweet.retweetedTweet {
                Label("Retweeted", systemImage: "arrow.2.squarepath")
                    .labelStyle(RetweetLabel())
                
                Button {
                    navManager.path.append(NavigationDestination.tweetDetail(Tweet(from: retweet)))
                } label: {
                    RetweetView(tweet: retweet)
                }
                .buttonStyle(.plain)
           }
        }
        .contentShape(.rect)
    }
}
