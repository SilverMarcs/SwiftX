//
//  BirdieApp.swift
//  Birdie
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import AVKit

@main
struct BirdieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 540, minHeight: 560)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 980, height: 800)
        #endif
    }
    
    #if !os(macOS)
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    }
    #endif
}
