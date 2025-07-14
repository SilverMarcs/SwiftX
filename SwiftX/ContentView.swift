//
//  ContentView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var imageNS
    
    var body: some View {
        TabView {
            Tab("Tweets", systemImage: "bird.fill") {
                HomeTab()
                    .environment(\.imageNS, imageNS)
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            
            // Tab(role: .search) {
            //     Text("TBI")
            // }
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
