//
//  TweetHeader.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct TweetHeader: View {
    let tweet: any TweetContentProtocol
    @Environment(\.appendToPath) private var appendToPath
    
    var body: some View {
        HStack {
            Button {
                appendToPath(tweet.user)
            } label: {
                UserHeader(user: tweet.user)
            }
            .buttonStyle(.plain)
            Spacer()
            Text(tweet.formattedDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
