import SwiftUI
import SwiftMediaViewer

/// Birdie's content over each page of the full-screen video viewer: a Save button,
/// shown with the controls just above the scrubber.
///
/// Saving only updates the post's saved state; the Saved tab's list itself
/// changes on its next refresh.
struct VideoPageOverlay: View {
    let page: SMVVideoPageContext
    private var bookmarks: XBookmarkStore { .shared }

    var body: some View {
        Group {
            if page.isShowingControls, let postID = Int(page.item.id) {
                let isSaved = bookmarks.isBookmarked(id: postID)
                Button(isSaved ? "Unsave Post" : "Save Post",
                       systemImage: isSaved ? "bookmark.fill" : "bookmark") {
                    Task { try? await bookmarks.toggle(id: postID) }
                }
                .labelStyle(.iconOnly)
                .contentTransition(.symbolEffect(.replace))
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                // Dark glass in light mode too, over the video's black backdrop.
                .environment(\.colorScheme, .dark)
                .disabled(bookmarks.isPending(postID) || !XSessionStore.shared.isAuthenticated)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .transition(.opacity)
            }
        }
        .onChange(of: page.isCurrent, initial: true) { _, isCurrent in
            if isCurrent { XSeenPosts.shared.markSeen(id: page.item.id) }
        }
    }
}
