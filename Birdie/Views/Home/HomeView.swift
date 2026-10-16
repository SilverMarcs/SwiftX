import SwiftUI

struct HomeView: View {
    @State private var model = TimelineStore()
    @State private var showingSettings = false
    @State private var auth = XAuthStore.shared
    @Namespace private var transition

    var body: some View {
        TimelineFeedView(model: model)
        .refreshable { await model.refresh() }
        .overlay {
            if !auth.isAuthenticated {
                ContentUnavailableView {
                    Label("Connect your X session", systemImage: "person.crop.circle.badge.exclamationmark")
                } description: {
                    Text(auth.loadError ?? "Add your saved X session in Settings to load your personalized For you feed.")
                } actions: {
                    Button("Open Settings", systemImage: "gear") { showingSettings = true }
                }
            } else if model.entries.isEmpty, model.nextCursor == nil {
                if model.isRefreshing {
                    UniversalProgressView()
                } else if let error = model.error {
                    ContentUnavailableView {
                        Label("Couldn’t load your feed", systemImage: "wifi.exclamationmark")
                    } description: { Text("\(error) Pull down to try again.") } actions: {
                        Button("Settings", systemImage: "gear") { showingSettings = true }
                    }
                } else {
                    ContentUnavailableView {
                        Label("No posts right now", systemImage: "text.bubble")
                    } description: { Text("Pull down to ask X for a new selection of posts.") }
                }
            }
        }
        .navigationTitle("Home")
        .toolbarTitleDisplayMode(.inlineLarge)
        .navigationSubtitle("\(model.entries.count) tweets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Settings", systemImage: "gear") { showingSettings = true }
            }
            #if !os(macOS)
            .matchedTransitionSource(id: "settings-button", in: transition)
            #endif
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack { SettingsView() }
            #if !os(macOS)
            .navigationTransition(.zoom(sourceID: "settings-button", in: transition))
            #endif
        }
        .task(id: auth.revision) {
            model.configure(accountKey: auth.isAuthenticated ? auth.session.accountKey : nil)
            guard auth.isAuthenticated, model.entries.isEmpty else { return }
            await model.refresh()
        }
    }
}
