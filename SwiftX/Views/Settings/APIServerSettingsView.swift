//
//  APIServerSettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct APIServerSettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var refreshAlertPresented = false
    @State private var isRefreshing = false
    @State private var refreshError: String?

    var body: some View {
        Section {
            Toggle(isOn: $settings.useWebserver) {
                Label {
                    Text("Use Webserver")
                } icon: {
                    Image(systemName: "network")
                }
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
                    HStack {
                        ProgressView()
                        Text("Refreshing")
                    }
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
        } header: {
            Text("API Endpoint")
        } footer: {
            Text("Using \(settings.useWebserver ? AppSettings.webserver : AppSettings.localhost)")
        }

        Section(header: Text("API Key")) {
            SecureField("Enter API Key", text: $settings.apiKey)
        }
    }
}
