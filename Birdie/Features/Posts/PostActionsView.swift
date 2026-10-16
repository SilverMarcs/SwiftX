import SwiftUI

struct PostActionsView: View {
    @Environment(NavigationPathManager.self) private var navigation
    let post: Post
    let showsOpenPost: Bool

    var body: some View {
        HStack(spacing: 20) {
            Group {
                Label(post.replyCount.formatted(.number.notation(.compactName)), systemImage: "message")
                    .accessibilityLabel("\(post.replyCount) replies")
                Label(post.repostCount.formatted(.number.notation(.compactName)), systemImage: "arrow.2.squarepath")
                    .accessibilityLabel("\(post.repostCount) reposts")
                Label(post.likeCount.formatted(.number.notation(.compactName)), systemImage: "heart")
                    .accessibilityLabel("\(post.likeCount) likes")
            }
            .lineLimit(1)

            Spacer()

            #if os(macOS)
            if showsOpenPost {
                Button("Open post", systemImage: "bubble") {
                    navigation.path.append(NavigationDestination.postDetail(post))
                }
                .buttonStyle(.plain)
                .labelStyle(.titleOnly)
            }
            #endif

            Menu {
                Section {
                    Button(post.user.name, systemImage: "person") {
                        navigation.path.append(NavigationDestination.userDetail(post.user))
                    }
                }
                if let url = post.webURL {
                    SwiftUI.Link(destination: url) { Label("Open in X", systemImage: "bird") }
                    ShareLink(item: url) { Label("Share", systemImage: "square.and.arrow.up") }
                }
            } label: {
                Label("Post options", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .padding(8)
                    .background(.background.secondary, in: .capsule)
            }
        }
        .labelStyle(CustomLabelStyle())
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .labelIconToTitleSpacing(4)
    }
}
