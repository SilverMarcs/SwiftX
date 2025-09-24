//
//  TweetHeader.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct TweetHeader: View {
    let tweet: any TweetContentProtocol
    
    var body: some View {
        HStack {
            NavigationLink(destination: UserDetailView(user: tweet.user)) {
                UserHeader(user: tweet.user)
            }
            .navigationLinkIndicatorVisibility(.hidden)
            
            Spacer()
            Text(tweet.formattedDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
