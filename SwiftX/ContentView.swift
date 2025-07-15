//
//  ContentView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var imageNS
    @Namespace private var videoNS

    var body: some View {
        TabView {
            Tab("Tweets", systemImage: "bird.fill") {
                HomeTab()
                    .environment(\.imageNS, imageNS)
                    .environment(\.videoNS, videoNS)
            }

            Tab("Settings", systemImage: "gear") {
                SettingsView()
                    .environment(\.videoNS, videoNS)
            }

            // Tab(role: .search) {
            //     Text("TBI")
            // }
        }
        .overlay {
            FullscreenVideoOverlay()
                .environment(\.videoNS, videoNS)
        }
        .tabViewStyle(.sidebarAdaptable)
        #if !os(macOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
}

#Preview {
    ContentView()
}
