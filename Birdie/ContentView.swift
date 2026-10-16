import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") { HomeTab() }
            Tab(role: .search) { SearchTab() }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSearchActivation(.searchTabSelection)
        .environment(\.openURL, OpenURLAction { url in
            let host = url.host()?.lowercased() ?? ""
            return .systemAction(prefersInApp: !(host == "youtu.be" || host == "youtube.com" || host.hasSuffix(".youtube.com")))
        })
    }
}
