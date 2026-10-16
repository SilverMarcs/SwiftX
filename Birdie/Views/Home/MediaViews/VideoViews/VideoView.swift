import SwiftUI
import SwiftMediaViewer

struct VideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true

    let video: Video
    @State private var showVideo = false
    
    var body: some View {
        #if os(macOS)
        MacVideoPlayer(video: video, autoplay: autoplay, muted: muteOnPlay)
            .clipShape(.rect(cornerRadius: 12))
            .aspectRatio(1, contentMode: .fit)
        #else
        Group {
            if showVideo {
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
                .task {
                    guard autoplay else { return }
                    do {
                        try await Task.sleep(for: .seconds(1))
                    } catch {
                        return
                    }
                    showVideo = true
                }
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .aspectRatio(1, contentMode: .fit)
        #endif
    }
}
