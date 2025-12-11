//
//  SettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                VideoPlaybackSettingsView()
                ImageCacheSettingsView()
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
