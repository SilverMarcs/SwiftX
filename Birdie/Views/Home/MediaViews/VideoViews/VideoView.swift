import SwiftUI
import SwiftMediaViewer

struct VideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true

    let video: Video
    @State private var showVideo = false
    
    var body: some View {
        Group {
            if autoplay || showVideo {
                SMVVideo(videoURL: video.variants.first?.url ?? "", autoplay: true, muteOnPlay: muteOnPlay)
            } else {
                Button(action: {
                    showVideo = true
                }) {
                    CachedAsyncImage(url: URL(string: video.thumbnailUrl), targetSize: 300)
                        .overlay(
                            Image(systemName: "play.fill")
                                .imageScale(.large)
                                .padding()
                                .glassEffect(in: .circle)
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .aspectRatio(1, contentMode: .fit)
    }
}
