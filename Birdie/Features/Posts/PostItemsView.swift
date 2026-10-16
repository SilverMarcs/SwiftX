import SwiftUI

struct PostItemsView: View {
    @Environment(NavigationPathManager.self) private var navigation
    let tweets: [Post]

    var body: some View {
        ForEach(tweets) { tweet in
            Group {
                #if os(iOS)
                Button {
                    navigation.path.append(NavigationDestination.postDetail(tweet))
                } label: {
                    PostView(tweet: tweet)
                }
                .buttonStyle(.plain)
                #else
                PostView(tweet: tweet)
                #endif
            }
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.visible, edges: .bottom)
                .listRowSeparator(.hidden, edges: .top)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
    }
}
