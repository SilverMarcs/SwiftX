import SwiftUI

/// Loading, empty, error and signed-out states shown over the saved posts list.
struct SavedPostsStatusView: View {
    let model: SavedPostsStore
    let isEmpty: Bool
    let signIn: () -> Void
    let retry: () -> Void

    var body: some View {
        if !XSessionStore.shared.isAuthenticated {
            ContentUnavailableView {
                Label("Sign in to X", systemImage: "person.crop.circle")
            } description: {
                Text("Sign in to see your saved posts.")
            } actions: {
                Button("Sign in to X", action: signIn)
                    .buttonStyle(.borderedProminent)
            }
        } else if isEmpty {
            if model.isLoading || model.isLoadingMore
                || (model.nextCursor != nil && model.paginationErrorMessage == nil) {
                UniversalProgressView()
            } else if let error = model.errorMessage ?? model.paginationErrorMessage {
                ContentUnavailableView {
                    Label("Couldn't Load Saved Posts", systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                } description: {
                    Text(error)
                } actions: {
                    Button("Try Again", systemImage: "arrow.clockwise", action: retry)
                }
            } else if model.hasLoaded {
                ContentUnavailableView("No Saved Posts", systemImage: "bookmark",
                                       description: Text("Posts you bookmark on X or in Birdie appear here."))
            }
        }
    }
}
