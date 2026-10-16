import SwiftUI

struct ReferencedPostView: View {
    let tweet: Post

    var body: some View {
        PostContentView(tweet: tweet)
            .padding(10)
            .background(.background.secondary)
            .clipShape(.rect(cornerRadius: 10))
    }
}
