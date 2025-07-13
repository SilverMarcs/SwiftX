//
//  VideoPlayerView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(width: 300, height: 300)
            .clipShape(.rect(cornerRadius: 10))
            .task {
                player = AVPlayer(url: url)
                player?.isMuted = true
                player?.play()
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
}
