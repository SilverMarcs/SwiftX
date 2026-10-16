import SwiftUI

struct PostView: View {
    let tweet: Post
    var showsOpenPost = true
    @Environment(NavigationPathManager.self) private var navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PostHeader(tweet: tweet)

            if tweet.repostedPost == nil {
                PostContentView(tweet: tweet, hideHeader: true, showsOpenPost: showsOpenPost)
            }

            if let quote = tweet.quotedPost {
                Button {
                    navigation.path.append(NavigationDestination.postDetail(quote))
                } label: {
                    ReferencedPostView(tweet: quote)
                }
                .buttonStyle(.plain)
            }

            if let repost = tweet.repostedPost {
                Label("Retweeted", systemImage: "arrow.2.squarepath")
                    .labelStyle(RetweetLabel())
                Button {
                    navigation.path.append(NavigationDestination.postDetail(repost))
                } label: {
                    ReferencedPostView(tweet: repost)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(.rect)
    }
}
