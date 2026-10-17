import Foundation
import WebKit

struct XLoginNavigationPolicy: WebPage.NavigationDeciding {
    func decidePolicy(for action: WebPage.NavigationAction, preferences: inout WebPage.NavigationPreferences) async -> WKNavigationActionPolicy {
        guard let url = action.request.url else { return .cancel }
        // Session capture is independently restricted to the main x.com frame.
        if url.scheme == "https" { return .allow }
        if url.absoluteString == "about:blank" { return .allow }
        if action.target?.isMainFrame == false, url.scheme == "blob" { return .allow }
        return .cancel
    }
}
