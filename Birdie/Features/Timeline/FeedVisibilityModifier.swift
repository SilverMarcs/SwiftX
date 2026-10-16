import SwiftUI

struct FeedVisibilityModifier: ViewModifier {
    let viewportHeight: Double
    let action: (Bool) -> Void

    func body(content: Content) -> some View {
        #if os(macOS)
        // Count visible and nearly visible rows; List also constructs off-screen rows.
        content.onGeometryChange(for: Bool.self) { proxy in
            let frame = proxy.frame(in: .named("timeline-viewport"))
            return viewportHeight > 0 && frame.maxY > -80 && frame.minY < viewportHeight + 80
        } action: { action($0) }
        #else
        content.onScrollVisibilityChange(threshold: 0.1, action)
        #endif
    }
}
