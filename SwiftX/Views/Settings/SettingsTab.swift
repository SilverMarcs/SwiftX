//
//  SettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Kingfisher

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var deleteAlertPresented = false
    @State private var cacheSize: String = "Calculating..."
    
    @State private var refreshAlertPresented = false
    @State private var isRefreshing = false
    @State private var refreshError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $settings.useWebserver) {
                        Label {
                            Text("Use Webserver")
                        } icon: {
                            Image(systemName: "network")
                        }
                    }
                } header: {
                    Text("API Endpoint")
                } footer: {
                    Text("Using \(settings.useWebserver ? "https://snscrape-production.up.railway.app" : "http://192.168.0.154:8000")")
                }
                
                Section(header: Text("API Key")) {
                    SecureField("Enter API Key", text: $settings.apiKey)
                }
                
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

                    Button {
                        Task {
                            isRefreshing = true
                            refreshError = nil
                            do {
                                try await TweetService.refreshTweetCache()
                                refreshAlertPresented = true
                            } catch {
                                refreshError = error.localizedDescription
                                refreshAlertPresented = true
                            }
                            isRefreshing = false
                        }
                    } label: {
                        if isRefreshing {
                            ProgressView()
                        } else {
                            Label("Refresh Tweet Cache", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(isRefreshing)
                    .alert(isPresented: $refreshAlertPresented) {
                        if let error = refreshError {
                            return Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
                        } else {
                            return Alert(title: Text("Success"), message: Text("Tweet cache refresh initiated. Check tweets in a few moments."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
            }
            .task {
                calculateCacheSize()
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
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

#Preview {
    SettingsView()
}
