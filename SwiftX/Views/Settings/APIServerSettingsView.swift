//
//  APIServerSettingsView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 15/07/2025.
//

import SwiftUI

struct APIServerSettingsView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
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
            Text("Using \(settings.useWebserver ? AppSettings.webserver : AppSettings.localhost)")
        }

        Section(header: Text("API Key")) {
            SecureField("Enter API Key", text: $settings.apiKey)
        }
    }
}
