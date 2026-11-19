import SwiftUI

struct SavedTab: View {
    @State private var navManager = NavigationPathManager()

    var body: some View {
        NavigationStack(path: $navManager.path) {
            SavedPostsView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .tweetDetail(let tweet):
                        TweetDetailView(tweet: tweet)
                    case .userDetail(let user):
                        UserDetailView(user: user)
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .environment(navManager)
    }
}

#Preview {
    SavedTab()
}
