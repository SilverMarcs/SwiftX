import SwiftUI

struct TweetContentView: View {
    let tweet: any TweetContentProtocol
    var hideHeader = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(NavigationPathManager.self) private var navManager

    var body: some View {
        VStack(alignment: .leading) {
            if !hideHeader {
                TweetHeader(tweet: tweet)
            }

            ExpandableText(text: tweet.parsedContent)
                .font(.body)

            ForEach(tweet.links, id: \.url) { link in
                if let url = URL(string: link.url) {
                    SwiftUI.Link(destination: url) {
                        Label(link.text ?? "Link", systemImage: "link")
                            .labelStyle(RetweetLabel())
                            .foregroundStyle(.blue)
                            .brightness(colorScheme == .dark ? 0.6 : 0)
                    }
                    .buttonStyle(.plain)
                }
            }

            if let media = tweet.media {
                MediaView(media: media)
            }

            HStack {
                TweetEngagementView(tweet: tweet)

                Spacer()

                Menu("Post actions", systemImage: "ellipsis") {
                    Button("@\(tweet.user.username)", systemImage: "person") {
                        navManager.path.append(NavigationDestination.userDetail(tweet.user))
                    }

                    if let url = tweet.twitterWebUrl {
                        SwiftUI.Link(destination: url) {
                            Label("Open in X", systemImage: "arrow.up.right")
                        }
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                .labelStyle(.iconOnly)
                .padding(8)
                .background(.background.secondary, in: .capsule)
            }
            .labelStyle(CustomLabelStyle())
            .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
    }
}
