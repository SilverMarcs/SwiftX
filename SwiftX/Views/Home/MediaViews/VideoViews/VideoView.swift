import SwiftUI
import AVKit

struct VideoView: View {
    @Environment(\.videoNS) private var videoNS
    @Namespace private var fallbackNS

    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true

    let video: Video

    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?

    var body: some View {
        if let url = URL(string: video.variants.first?.url ?? "") {
            VideoPlayer(player: player)
                .aspectRatio(16/9, contentMode: .fit)
                .matchedGeometryEffect(id: video.variants.first?.url ?? "videoPlayer", in: videoNS ?? fallbackNS)
                .cornerRadius(12)
                .clipped()
                .onTapGesture {
                    VideoOverlayViewModel.shared.present(player: player, videoURL: video.variants.first?.url)
                }
                .task {
                    await setupPlayer(url: url)
                }
                .onDisappear {
                    cleanupPlayer()
                }
        }
    }

    private func setupPlayer(url: URL) async {
        guard player == nil else { return }

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredPeakBitRate = 2_000_000

        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = muteOnPlay

        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer

        if autoplay {
            queuePlayer.play()
        }
    }

    private func cleanupPlayer() {
        player?.pause()
        playerLooper?.disableLooping()
        playerLooper = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
}
