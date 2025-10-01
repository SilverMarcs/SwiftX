import SwiftUI
import SwiftMediaViewer

struct VideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true

    let video: Video
    @State private var showVideo = false
    
    var body: some View {
        Group {
            if showVideo {
                SMVVideo(videoURL: video.variants.first?.url ?? "", autoplay: true, muteOnPlay: muteOnPlay)
            } else {
                CachedAsyncImage(url: URL(string: video.thumbnailUrl), targetSize: 300)

                    .overlay(
                        Image(systemName: "play.fill")
                            .imageScale(.large)
                            .padding()
                            .glassEffect(in: .circle)
                            .foregroundStyle(.white)
                    )
                    .onTapGesture {
                        showVideo = true
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .aspectRatio(1, contentMode: .fit)
    }
}
