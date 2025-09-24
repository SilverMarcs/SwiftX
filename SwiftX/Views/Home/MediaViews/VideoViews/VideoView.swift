import SwiftUI
import SwiftMediaViewer

struct VideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true

    let video: Video
    
    var body: some View {
        SMVVideo(videoURL: video.variants.first?.url ?? "", autoplay: autoplay, muteOnPlay: muteOnPlay)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .clipped()
    }
}
