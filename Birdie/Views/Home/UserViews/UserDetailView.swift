import SwiftUI

struct UserDetailView: View {
    let user: User
    @State private var model = ProfileStore()

    var body: some View {
        let profile = model.profile ?? user
        List {
            UserProfileHeader(user: profile)
            if let error = model.error { FeedErrorView(message: error, retry: reload) }
            if model.isLoading {
                UniversalProgressView()
                    .padding(.top, 100)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
            }
            PostItemsView(tweets: model.posts)
        }
        .listStyle(.plain)
        .navigationTitle(profile.name)
        .toolbarTitleDisplayMode(.inline)
        .task(id: user.id) {
            if model.profile == nil { await model.load(userID: user.id) }
        }
        .refreshable { await model.load(userID: user.id) }
    }

    private func reload() { Task { await model.load(userID: user.id) } }
}
