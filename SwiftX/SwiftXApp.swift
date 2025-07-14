//
//  SwiftXApp.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import AVKit
import Kingfisher

@main
struct SwiftXApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 1024 * 1024 * 60 // 60 MB
        ImageCache.default.diskStorage.config.sizeLimit = 1024 * 1024 * 200 // 200 MB
        ImageCache.default.diskStorage.config.expiration = .days(2) // 3 day
        
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }
}
