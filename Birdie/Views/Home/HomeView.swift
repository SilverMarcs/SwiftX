import SwiftUI

struct HomeView: View {
    @State private var model = FollowingStore()
    @State private var sort: FollowingSort = .recent
    @State private var showingSignIn = false
    private var session: XSessionStore { .shared }

    var body: some View {
        List {
            TweetItemsView(tweets: model.tweets)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)

            if !model.tweets.isEmpty, let error = model.errorMessage {
                FollowingRetryRow(message: error) { await refresh() }
            }

            if model.nextCursor != nil {
                if let error = model.paginationErrorMessage {
                    if !model.tweets.isEmpty {
                        FollowingRetryRow(message: error) { await model.loadNextPage() }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        .task(id: model.nextCursor) { await model.loadNextPage() }
                }
            }
        }
        .listStyle(.plain)
        .refreshable { await refresh() }
        .task(id: "\(sort.rawValue)-\(session.revision)-\(session.followingRevision)") { await refresh() }
        .overlay {
            if !session.isAuthenticated {
                ContentUnavailableView {
                    Label("Sign in to X", systemImage: "person.crop.circle")
                } description: {
                    Text("See posts from the people you follow.")
                } actions: {
                    Button("Sign in to X") { showingSignIn = true }
                        .buttonStyle(.borderedProminent)
                        .disabled(session.isSigningOut)
                }
            } else if model.tweets.isEmpty {
                if model.isLoading || model.isLoadingMore || (model.nextCursor != nil && model.paginationErrorMessage == nil) {
                    UniversalProgressView()
                } else if let error = model.errorMessage ?? model.paginationErrorMessage {
                    ContentUnavailableView {
                        Label("Couldn't Load Feed", systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try Again") {
                            Task {
                                if model.paginationErrorMessage != nil {
                                    await model.loadNextPage()
                                } else {
                                    await refresh()
                                }
                            }
                        }
                    }
                } else if model.hasLoaded {
                    ContentUnavailableView {
                        Label("No Posts Yet", systemImage: "text.bubble")
                    } description: {
                        Text("Posts from people you follow will appear here.")
                    } actions: {
                        Button("Refresh") { Task { await refresh() } }
                    }
                }
            }
        }
        .navigationTitle("Feed")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Feed Order", selection: $sort) {
                        ForEach(FollowingSort.allCases) { order in
                            Label(order.rawValue, systemImage: order == .recent ? "clock" : "heart")
                                .tag(order)
                        }
                    }
                } label: {
                    Label(sort.rawValue, systemImage: "line.3.horizontal.decrease")
                }
                .accessibilityLabel("Feed order: \(sort.rawValue)")
            }
        }
        .sheet(isPresented: $showingSignIn) { SignInView() }
    }

    private func refresh() async {
        await model.load(sort: sort, sessionRevision: session.revision, isAuthenticated: session.isAuthenticated)
    }
}

#Preview {
    NavigationStack { HomeView() }
}
