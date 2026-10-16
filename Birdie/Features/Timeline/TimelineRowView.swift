import SwiftUI

struct TimelineRowView: View {
    @Environment(NavigationPathManager.self) private var navigation
    let entry: TimelineEntry

    var body: some View {
        VStack(alignment: .leading) {
            if entry.isPromoted { Text("Promoted").font(.caption).foregroundStyle(.secondary) }
            if let context = entry.context {
                Text(context).font(.subheadline).foregroundStyle(.secondary)
            }
            #if os(iOS)
            Button {
                navigation.path.append(NavigationDestination.postDetail(entry.post))
            } label: {
                PostView(tweet: entry.post)
            }
            .buttonStyle(.plain)
            #else
            PostView(tweet: entry.post)
            #endif
        }
    }
}
