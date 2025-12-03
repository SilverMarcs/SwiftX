//
//  TweetHeader.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct TweetHeader: View {
    let tweet: any TweetContentProtocol
    @Environment(NavigationPathManager.self) private var navManager
    
    var body: some View {
        HStack {
            Button {
                navManager.path.append(NavigationDestination.userDetail(tweet.user))
            } label: {
                UserHeader(user: tweet.user)
            }
            .buttonStyle(.plain)
            
            Spacer()
            Text(tweet.date, format: .relative(presentation: .named, unitsStyle: .narrow))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
