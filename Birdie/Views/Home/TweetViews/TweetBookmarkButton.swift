import SwiftUI

struct TweetBookmarkButton: View {
    let tweet: any TweetContentProtocol
    @State private var errorMessage: String?
    @State private var showingError = false
    private var bookmarks: XBookmarkStore { .shared }

    var body: some View {
        Button(bookmarks.isBookmarked(tweet) ? "Unsave post" : "Save post",
               systemImage: bookmarks.isBookmarked(tweet) ? "bookmark.fill" : "bookmark",
               action: toggle)
        .labelStyle(.iconOnly)
        .font(.subheadline)
        .imageScale(.small)
        .buttonStyle(.plain)
        .disabled(bookmarks.isPending(tweet.id) || !XSessionStore.shared.isAuthenticated)
        .accessibilityValue(bookmarks.isBookmarked(tweet) ? "Saved" : "Not saved")
        .alert("Couldn't Update Saved Post", isPresented: $showingError) { } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private func toggle() {
        Task {
            do {
                try await bookmarks.toggle(tweet)
            } catch {
                guard !Task.isCancelled, !(error is CancellationError) else { return }
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}
