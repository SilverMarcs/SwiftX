//
//  SettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            VideoPlaybackSettingsView()
            ImageCacheSettingsView()
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            Button(role: .close) {
                dismiss()
            }
        }
    }
}

#Preview {
    SettingsView()
}
