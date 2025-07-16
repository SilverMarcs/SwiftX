//
//  ImageCacheSettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct ImageCacheSettingsView: View {
    @State private var deleteAlertPresented = false
    @State private var cacheSize: String = "Calculating..."

    var body: some View {
        Section("Images") {
            Button {
                deleteAlertPresented = true
            } label: {
                HStack {
                    Label {
                        Text("Clear Image Cache")
                    } icon: {
                        Image(systemName: "trash")
                    }
                    Spacer()
                    Text("{Cache Size}")
                }
                .contentShape(.rect)
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
            .alert("Clear Image Cache", isPresented: $deleteAlertPresented) {
                Button("Clear", role: .destructive) {
                    Task {
                        await MemoryCache.shared.clearCache()
                        await DiskCache.shared.clearCache()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will clear all cached images, freeing up storage space.")
            }
        }
    }
}
