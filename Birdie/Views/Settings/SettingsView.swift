//
//  SettingsView.swift
//  Birdie
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

#if os(iOS)
private enum SettingsRoute: Hashable {
    case appIcon
}
#endif

struct SettingsView: View {
    #if os(iOS)
    @AppStorage("showAppIconPicker") private var showAppIconPicker = false
    @State private var easterEggTapCount = 0
    #endif

    var body: some View {
        Form {
            XAccountSettingsView()
            VideoPlaybackSettingsView()
            ImageCacheSettingsView()
            SupportSettingsView()
            #if os(iOS)
            if showAppIconPicker && AppIconStore.supportsAlternateIcons {
                Section {
                    NavigationLink(value: SettingsRoute.appIcon) {
                        Label("App Icon", systemImage: "app.dashed")
                    }
                }
            }
            #endif
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        #if os(iOS)
        .navigationDestination(for: SettingsRoute.self) { route in
            switch route {
            case .appIcon:
                AppIconPicker()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if AppIconStore.supportsAlternateIcons {
                Button(action: revealAppIconPicker) {
                    Text("More settings")
                        .foregroundStyle(.clear)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
        #endif
    }

    #if os(iOS)
    private func revealAppIconPicker() {
        guard !showAppIconPicker else { return }
        easterEggTapCount += 1
        if easterEggTapCount >= 7 {
            showAppIconPicker = true
            easterEggTapCount = 0
        }
    }
    #endif
}

#Preview {
    SettingsView()
}
