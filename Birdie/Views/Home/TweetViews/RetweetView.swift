//
//  TweetView 2.swift
//  Birdie
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct RetweetView: View {
    let tweet: Retweet
    
    var body: some View {
        TweetContentView(tweet: tweet)
            .padding(10)
            .background(.background.secondary)
            .clipShape(.rect(cornerRadius: 10))
    }
}
