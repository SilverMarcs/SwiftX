#if os(macOS)
import AVKit
import SwiftUI

/// Keeps inline playback independent of AVPlayerView's observer lifecycle.
struct MacPlayerSurface: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        view.wantsLayer = true
        view.layer = layer
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        guard let layer = view.layer as? AVPlayerLayer else { return }
        if layer.player !== player { layer.player = player }
    }

    static func dismantleNSView(_ view: NSView, coordinator: ()) {
        let layer = view.layer as? AVPlayerLayer
        layer?.player?.pause()
        layer?.player = nil
    }
}
#endif
