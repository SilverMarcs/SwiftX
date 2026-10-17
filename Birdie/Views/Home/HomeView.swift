import SwiftUI

struct HomeView: View {
    @State private var model = FeedStore()
    @State private var filter: FeedFilter = .recent
    @State private var showingSignIn = false
    private var session: XSessionStore { .shared }

    var body: some View {
        List {
            TweetItemsView(tweets: model.tweets)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)

            if !model.tweets.isEmpty, let error = model.errorMessage {
                FeedRetryRow(message: error) { await refresh() }
            }

            if model.nextCursor != nil {
                if let error = model.paginationErrorMessage {
                    if !model.tweets.isEmpty {
                        FeedRetryRow(message: error) { await model.loadNextPage() }
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
        .task(id: filter) {
            await model.loadIfNeeded(filter: filter, sessionRevision: session.revision, isAuthenticated: session.isAuthenticated)
        }
        .overlay {
            if !session.isAuthenticated {
                ContentUnavailableView {
                    Label("Sign in to X", systemImage: "person.crop.circle")
                } description: {
                    Text("Sign in to see your feed.")
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
                        Text(filter.emptyMessage)
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
                    Picker("Feed", selection: $filter) {
                        ForEach(FeedFilter.allCases) { option in
                            Label(option.rawValue, systemImage: option.systemImage)
                                .tag(option)
                        }
                    }
                } label: {
                    Label(filter.rawValue, systemImage: "line.3.horizontal.decrease")
                }
                .accessibilityLabel("Feed: \(filter.rawValue)")
            }
        }
        .sheet(isPresented: $showingSignIn) { SignInView() }
    }

    private func refresh() async {
        await model.load(filter: filter, sessionRevision: session.revision, isAuthenticated: session.isAuthenticated)
    }
}

#Preview {
    NavigationStack { HomeView() }
}
