import SwiftUI

struct PostDetailView: View {
    let tweet: Post
    @State private var model = PostDetailStore()

    var body: some View {
        List {
            PostView(tweet: tweet, showsOpenPost: false)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden, edges: .top)
                .listRowSeparator(.visible, edges: .bottom)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            if model.isLoading {
                UniversalProgressView()
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
            }
            if let error = model.error { FeedErrorView(message: error, retry: reload) }
            if !model.replies.isEmpty {
                Text("Replies")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 800, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                PostItemsView(tweets: model.replies)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Tweet")
        .toolbarTitleDisplayMode(.inline)
        .task(id: tweet.id) {
            if model.replies.isEmpty { await model.load(postID: tweet.id) }
        }
    }

    private func reload() { Task { await model.load(postID: tweet.id) } }
}
