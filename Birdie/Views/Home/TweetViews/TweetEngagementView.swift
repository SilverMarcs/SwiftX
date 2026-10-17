import SwiftUI

struct TweetEngagementView: View {
    let tweet: any TweetContentProtocol

    var body: some View {
        HStack {
            Label {
                Text(tweet.replyCount, format: .number.notation(.compactName))
            } icon: {
                Image(systemName: "message")
            }
            .accessibilityLabel("\(tweet.replyCount) replies")

            Label {
                Text(tweet.retweetCount, format: .number.notation(.compactName))
            } icon: {
                Image(systemName: "arrow.2.squarepath")
            }
            .accessibilityLabel("\(tweet.retweetCount) reposts")

            Label {
                Text(tweet.likeCount, format: .number.notation(.compactName))
            } icon: {
                Image(systemName: "heart")
            }
            .accessibilityLabel("\(tweet.likeCount) likes")
        }
        .lineLimit(1)
    }
}
