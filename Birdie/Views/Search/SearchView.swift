import SwiftUI

struct SearchView: View {
    @State private var model = SearchStore()
    @State private var showsSignIn = false
    @Environment(NavigationPathManager.self) private var navManager

    var body: some View {
        Group {
            if XSessionStore.shared.isAuthenticated {
                List {
                    switch model.scope {
                    case .tweets:
                        TweetItemsView(tweets: model.tweets)
                    case .users:
                        ForEach(model.users, id: \.id) { user in
                            Button {
                                navManager.path.append(NavigationDestination.userDetail(user))
                            } label: {
                                HStack {
                                    UserHeader(user: user)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if model.isLoading {
                        UniversalProgressView()
                    } else if let error = model.errorMessage {
                        ContentUnavailableView {
                            Label("Search Failed", systemImage: "exclamationmark.magnifyingglass")
                        } description: {
                            Text(error)
                        } actions: {
                            Button("Try Again", action: model.submit)
                        }
                    } else if model.hasSearched, model.tweets.isEmpty, model.users.isEmpty {
                        ContentUnavailableView.search(text: model.submittedQuery)
                    } else if !model.hasSearched {
                        ContentUnavailableView("Search X", systemImage: "magnifyingglass", description: Text("Find posts and people on X."))
                    }
                }
                .searchable(text: $model.query, placement: .toolbarPrincipal, prompt: "Search \(model.scope.rawValue)")
                .searchScopes($model.scope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .onSubmit(of: .search, model.submit)
                .onChange(of: model.scope) { model.submit() }
                .onChange(of: model.query) {
                    if model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { model.clear() }
                }
                .task(id: model.requestID) { await model.load() }
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear Search", systemImage: "eraser", action: model.clear)
                            .disabled(model.query.isEmpty && model.tweets.isEmpty && model.users.isEmpty)
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("Search X", systemImage: "magnifyingglass")
                } description: {
                    Text("Sign in to find posts and people on X.")
                } actions: {
                    Button("Sign in to X") { showsSignIn = true }
                        .buttonStyle(.borderedProminent)
                        .disabled(XSessionStore.shared.isSigningOut)
                }
            }
        }
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inlineLarge)
        .onChange(of: XSessionStore.shared.revision) { model.clear() }
        .sheet(isPresented: $showsSignIn) { SignInView() }
    }
}
