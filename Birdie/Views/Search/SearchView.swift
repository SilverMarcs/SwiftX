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
                                UserHeader(user: user)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden, edges: .top)
                            .listRowSeparator(.visible, edges: .bottom)
                        }
                    }
                }
                .listStyle(.plain)
                .contentMargins(.top, 5, for: .scrollContent)
                .overlay {
                    if model.isLoading, !model.submittedQuery.isEmpty {
                        UniversalProgressView()
                    } else if let error = model.errorMessage {
                        ContentUnavailableView {
                            Label("Search Failed", systemImage: "exclamationmark.magnifyingglass")
                        } description: {
                            Text(error)
                        }
                    } else if model.hasSearched, model.isEmpty {
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
                .onSubmit(of: .search) {
                    Task { await model.submit() }
                }
                .onChange(of: model.scope) {
                    Task { await model.loadIfNeeded() }
                }
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
