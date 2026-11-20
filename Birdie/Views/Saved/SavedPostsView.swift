import SwiftUI

struct SavedPostsView: View {
    @State private var model = SavedPostsStore()
    @State private var showingSignIn = false
    /// Not remembered: Saved always opens newest first.
    @State private var order: SavedPostsOrder = .recent
    private var session: XSessionStore { .shared }

    var body: some View {
        let tweets = model.visibleTweets(in: order)
        ScrollViewReader { proxy in
            List {
                TweetItemsView(tweets: tweets)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)

                if !tweets.isEmpty, let error = model.errorMessage {
                    FeedRetryRow(message: error) { await model.load() }
                }

                // Both orders page the same way: each new page arrives shuffled in Shuffled.
                if model.nextCursor != nil {
                    if let error = model.paginationErrorMessage {
                        FeedRetryRow(message: error) { await model.loadNextPage() }
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .task(id: model.nextCursor) { await model.loadNextPage() }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Saved")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    // Stays enabled signed out, since it also leads to Settings.
                    SavedPostsOrderMenu(order: $order) { shuffleAgain(proxy) }
                }
            }
            .refreshable { await model.load() }
            // Runs on first appearance and on signing in or out, never on switching accounts.
            .task(id: session.isAuthenticated) { await model.loadIfNeeded() }
            .overlay {
                SavedPostsStatusView(model: model, isEmpty: tweets.isEmpty,
                                     signIn: signIn, retry: retry)
            }
            .sheet(isPresented: $showingSignIn) { SignInView() }
        }
    }

    /// Reshuffles the loaded posts and starts again from the top.
    private func shuffleAgain(_ proxy: ScrollViewProxy) {
        model.shuffle()
        if let first = model.shuffledTweets.first {
            proxy.scrollTo(first.id, anchor: .top)
        }
    }

    private func signIn() {
        showingSignIn = true
    }

    private func retry() {
        Task {
            if model.paginationErrorMessage != nil, model.hasLoaded {
                await model.loadNextPage()
            } else {
                await model.load()
            }
        }
    }
}

#Preview {
    NavigationStack { SavedPostsView() }
        .environment(NavigationPathManager())
}
