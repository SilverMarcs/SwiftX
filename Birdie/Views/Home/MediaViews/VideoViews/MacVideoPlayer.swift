#if os(macOS)
import AVKit
import SwiftUI

struct MacVideoPlayer: View {
    let video: Video
    let autoplay: Bool
    let muted: Bool
    @State private var player = AVPlayer()
    @State private var isPlaying = false
    @State private var isMuted = true

    var body: some View {
        MacPlayerSurface(player: player)
            .overlay(alignment: .bottom) {
                HStack {
                    Button(isPlaying ? "Pause video" : "Play video", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                        if isPlaying { player.pause() }
                        else {
                            if player.currentItem?.currentTime() == player.currentItem?.duration { player.seek(to: .zero) }
                            player.play()
                        }
                        isPlaying.toggle()
                    }
                    if let duration = video.duration, duration > 0 {
                        TimelineView(.periodic(from: .now, by: 1)) { _ in
                            Slider(value: Binding(
                                get: { min(max(player.currentTime().seconds.isFinite ? player.currentTime().seconds : 0, 0), Double(duration) / 1_000) },
                                set: { player.seek(to: CMTime(seconds: $0, preferredTimescale: 600)) }
                            ), in: 0...(Double(duration) / 1_000)) {
                                Text("Video position")
                            }
                        }
                    } else { Spacer() }
                    Button(isMuted ? "Unmute video" : "Mute video", systemImage: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill") {
                        isMuted.toggle()
                        player.isMuted = isMuted
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .padding()
                .background(.ultraThinMaterial)
            }
            .task(id: video) {
                let variant = video.variants.filter { $0.contentType == "video/mp4" }
                    .max { ($0.bitrate ?? 0) < ($1.bitrate ?? 0) } ?? video.variants.first
                guard let variant, let url = URL(string: variant.url) else { return }
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                player.isMuted = muted
                isMuted = muted
                isPlaying = autoplay
                if autoplay { player.play() }
            }
            .onDisappear { player.pause() }
    }
}
#endif
