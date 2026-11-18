import SwiftUI
import SwiftMediaViewer

extension View {
    /// The full-screen video viewer as Birdie shows it, for each tab's stack.
    func birdieVideoViewerDestination() -> some View {
        smvVideoViewerDestination(scrubber: .withControls) { page in
            VideoPageOverlay(page: page)
        }
    }
}
