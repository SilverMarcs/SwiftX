//
//  ImageCacheSettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI
import Kingfisher

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
                    Text("\(cacheSize)")
                }
                .contentShape(.rect)
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
            .alert("Clear Image Cache", isPresented: $deleteAlertPresented) {
                Button("Clear", role: .destructive) {
                    ImageCache.default.clearCache()
                    calculateCacheSize()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will clear all cached images, freeing up storage space.")
            }
        }
        .task {
            calculateCacheSize()
        }
    }

    private func calculateCacheSize() {
        ImageCache.default.calculateDiskStorageSize { result in
            Task { @MainActor in
                switch result {
                case .success(let size):
                    self.cacheSize = unsafe String(format: "%.2f MB", Double(size) / 1024 / 1024)
                case .failure:
                    self.cacheSize = "Unknown"
                }
            }
        }
    }
}
