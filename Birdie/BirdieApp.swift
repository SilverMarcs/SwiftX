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
        }
    }
    
    #if !os(macOS)
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
    }
    #endif
}
