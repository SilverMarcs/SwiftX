import SwiftUI

struct UserDetailView: View {
    @State private var store: XProfileStore

    init(user: User) {
        _store = State(initialValue: XProfileStore(user: user))
    }

    var body: some View {
        List {
            UserProfileHeaderView(store: store) {
                Task { await store.toggleFollowing() }
            }
            .listRowSeparator(.hidden, edges: .top)
            .listRowSeparator(.visible, edges: .bottom)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity)

            if let message = store.profileErrorMessage {
                ContentUnavailableView {
                    Label("Couldn’t Load Profile", systemImage: "person.crop.circle.badge.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") { Task { await store.load() } }
                }
            }

            if let message = store.relationshipErrorMessage {
                VStack(alignment: .leading) {
                    Label("Couldn’t Update Following", systemImage: "exclamationmark.circle")
                        .bold()
                    Text(message)
                        .foregroundStyle(.secondary)
                    Button("Try Again") {
                        Task { await store.toggleFollowing() }
                    }
                    .disabled(!store.canChangeFollowing)
                }
                .accessibilityElement(children: .contain)
            }

            if store.isLoading && store.tweets.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if let message = store.tweetsErrorMessage {
                ContentUnavailableView {
                    Label("Couldn’t Load Posts", systemImage: "exclamationmark.bubble")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") { Task { await store.load() } }
                }
            } else if store.tweets.isEmpty {
                ContentUnavailableView("No Posts", systemImage: "text.bubble", description: Text("Posts from this account will appear here."))
            }

            TweetItemsView(tweets: store.tweets)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
        }
        .listStyle(.plain)
        .navigationTitle(store.user.displayname)
        .toolbarTitleDisplayMode(.inline)
        .task(id: XSessionStore.shared.revision) {
            await store.load()
        }
        .refreshable { await store.load() }
    }
}
