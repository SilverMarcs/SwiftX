//
//  SettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared

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
