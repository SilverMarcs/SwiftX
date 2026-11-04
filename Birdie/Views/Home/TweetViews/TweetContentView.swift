import SwiftUI

struct TweetContentView: View {
    let tweet: any TweetContentProtocol
    var hideHeader = false
    /// Shows a Reply button beside the actions menu when set.
    var onReply: (() -> Void)?
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

                HStack {
                    if let onReply {
                        Button(action: onReply) {
                            // Smaller glyph and no vertical padding, so the menu sets the row height.
                            Label("Reply", systemImage: "arrowshape.turn.up.left")
                                .labelStyle(.iconOnly)
                                .font(.caption)
                                .frame(maxHeight: .infinity)
                                .padding(.horizontal, 10)
                                .background(.background.secondary, in: .capsule)
                                .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                    }

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
                    .frame(maxHeight: .infinity)
                    .padding(8)
                    .background(.background.secondary, in: .capsule)
                }
                // Keeps the Reply and menu capsules the same height.
                .fixedSize(horizontal: false, vertical: true)
            }
            .labelStyle(CustomLabelStyle())
            .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
    }
}
