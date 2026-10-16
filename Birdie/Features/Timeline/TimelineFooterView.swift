import SwiftUI

struct TimelineFooterView: View {
    let model: TimelineStore
    @State private var isVisible = false

    var body: some View {
        VStack {
            if let error = model.loadMoreError {
                FeedErrorView(message: error, retry: loadMore)
            } else if model.isLoadingMore {
                ProgressView("Loading more posts…")
            } else if model.nextCursor != nil {
                Button("Load more", systemImage: "arrow.down", action: loadMore)
            } else {
                Text("You’ve reached the end of this feed.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Refresh for more recommendations.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .onScrollVisibilityChange(threshold: 0.1) { isVisible = $0 }
        .task(id: isVisible ? model.nextCursor : nil) {
            if isVisible, model.loadMoreError == nil { await model.loadMore() }
        }
    }

    private func loadMore() { Task { await model.loadMore() } }
}
