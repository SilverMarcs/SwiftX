import SwiftUI

/// Layout decisions that depend on the kind of device rather than the window size.
enum DeviceLayout {
    /// iPad and Mac show tabs in a sidebar, where Settings gets its own entry.
    /// iPhone keeps Settings in each tab's filter menu.
    static var usesSidebar: Bool {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad
        #else
        true
        #endif
    }

    /// Settings uses a large inline title on iPad and a compact one on iPhone.
    static var settingsTitleDisplayMode: ToolbarTitleDisplayMode {
        usesSidebar ? .inlineLarge : .inline
    }
}
