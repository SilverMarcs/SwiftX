import SwiftUI

struct PostContentView: View {
    let tweet: Post
    var hideHeader = false
    var showsOpenPost = true
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !hideHeader { PostHeader(tweet: tweet) }
            ExpandableText(text: tweet.parsedContent)
                .font(.default)
                .opacity(0.9)
            ForEach(tweet.links, id: \.url) { link in
                SwiftUI.Link(destination: link.url) {
                    Label(link.label, systemImage: "link")
                        .labelStyle(RetweetLabel())
                        .foregroundStyle(.blue)
                        .brightness(colorScheme == .dark ? 0.6 : 0)
                }
                .buttonStyle(.plain)
            }
            if let media = tweet.media { MediaView(media: media) }
            PostActionsView(post: tweet, showsOpenPost: showsOpenPost)
        }
        .contentShape(.rect)
    }
}
