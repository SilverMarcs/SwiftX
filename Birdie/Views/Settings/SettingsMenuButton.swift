import SwiftUI

/// The last item of a tab's filter menu: opens Settings on that tab's stack.
/// Not shown where Settings has its own sidebar entry.
struct SettingsMenuButton: View {
    @Environment(NavigationPathManager.self) private var navManager

    var body: some View {
        if !DeviceLayout.usesSidebar {
            Section {
                Button("Settings", systemImage: "gear", action: openSettings)
            }
        }
    }

    private func openSettings() {
        navManager.path.append(NavigationDestination.settings)
    }
}
