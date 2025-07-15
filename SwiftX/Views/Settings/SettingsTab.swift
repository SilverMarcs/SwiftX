//
//  SettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Kingfisher

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                APIServerSettingsView()
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
