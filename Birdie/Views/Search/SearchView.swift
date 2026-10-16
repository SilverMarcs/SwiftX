import SwiftUI

struct SearchView: View {
    @State private var model = SearchStore()
    @Environment(NavigationPathManager.self) private var navigation

    var body: some View {
        List {
            if let error = model.error { Text(error).foregroundStyle(.secondary) }
            if model.scope == .posts {
                PostItemsView(tweets: model.posts)
            } else {
                ForEach(model.users) { user in
                    Button {
                        navigation.path.append(NavigationDestination.userDetail(user))
                    } label: {
                        HStack {
                            UserHeader(user: user)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary.opacity(0.6))
                                .font(.footnote)
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
            }
        }
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inlineLarge)
        .searchable(text: $model.query, placement: .toolbarPrincipal, prompt: "Search \(model.scope.rawValue)")
        .searchScopes($model.scope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in Text(scope.rawValue).tag(scope) }
        }
        .onSubmit(of: .search) { Task { await model.search() } }
        .onChange(of: model.scope) { Task { await model.search() } }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Clear search", systemImage: "eraser", role: .destructive) { model.clear() }
                    .labelStyle(.iconOnly)
                    .disabled(model.query.isEmpty && model.posts.isEmpty && model.users.isEmpty)
            }
        }
    }
}
