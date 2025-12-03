//
//  TweetContentView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct TweetContentView: View {
    let tweet: any TweetContentProtocol
    var hideHeader: Bool = false
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            if !hideHeader {
                TweetHeader(tweet: tweet)
            }
            
            // Tweet Content
            ExpandableText(text: tweet.parsedContent)
                .font(.default)
                .opacity(0.9)
            
            ForEach(tweet.links, id: \.url) { url in
                Button {
                    openURL(URL(string: url.url)!)
                } label: {
                    Label(url.text ?? "Link", systemImage: "link")
                        .labelStyle(RetweetLabel())
                        .foregroundStyle(.blue)
                        .brightness(colorScheme == .dark ? 0.6 : 0)
                }
                .buttonStyle(.plain)
            }
            
            // Media Preview
            if let media = tweet.media {
                MediaView(media: media)
            }
            
            // Engagement Stats
            HStack(spacing: 20) {
                Group{
                    Label {
                        Text(tweet.replyCount, format: .number.notation(.compactName))
                    } icon: {
                        Image(systemName: "message")
                    }

                    Label {
                        Text(tweet.retweetCount, format: .number.notation(.compactName))
                    } icon: {
                        Image(systemName: "arrow.2.squarepath")
                    }

                    Label {
                        Text(tweet.likeCount, format: .number.notation(.compactName))
                    } icon: {
                        Image(systemName: "heart")
                    }
                }
                .lineLimit(1)
                
                Spacer()
                
                Menu {
                    SwiftUI.Link(destination: tweet.twitterWebUrl!) {
                        Label("Open in X", systemImage: "bird")
                    }
                    
                    ShareLink("Share", item: tweet.twitterWebUrl!)
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(10)
                }
                .glassEffect()
            }
            .labelStyle(CustomLabelStyle())
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .labelIconToTitleSpacing(4)
        }
        .contentShape(.rect)
    }
}


struct ExpandableText: View {
    let text: String
    let maxCharacters: Int
    
    @State private var isExpanded = false
    private let needsExpansion: Bool
    
    init(text: String, maxCharacters: Int = 400) {
        self.text = text
        self.maxCharacters = maxCharacters
        self.needsExpansion = text.count > maxCharacters
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(displayedText)
                .textSelection(.enabled)
                .lineSpacing(2)
            
            if needsExpansion {
                Button {
                    isExpanded.toggle()
                } label: {
                    Text(isExpanded ? "Show Less" : "Show More")
                        .contentShape(.rect)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
            }
        }
    }
    
    private var displayedText: String {
        guard needsExpansion && !isExpanded else {
            return text
        }
        return String(text.prefix(maxCharacters))
    }
}
