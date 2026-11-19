import SwiftUI
import SwiftMediaViewer

struct VideoView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = true

    let video: Video
    let tweet: any TweetContentProtocol
    @State private var showVideo = false

    var body: some View {
        Group {
            if autoplay || showVideo {
                // Loads at once over X's poster frame, so the video starts on the
                // thumbnail and takes over in place. Autoplay waits briefly so
                // videos flicked past don't start playing.
                SMVVideo(videoURL: video.variants.first?.url ?? "",
                         thumbnailURL: URL(string: video.thumbnailUrl),
                         autoplay: true,
                         autoplayDelay: showVideo ? .zero : .milliseconds(300),
                         muteOnPlay: muteOnPlay,
                         viewer: .custom(itemID: String(tweet.id), scrubber: .withControls, feed: makeFeed) { page in
                             VideoPageOverlay(page: page)
                         })
            } else {
                Button(action: play) {
                    CachedAsyncImage(url: URL(string: video.thumbnailUrl), targetSize: 600)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            Image(systemName: "play.fill")
                                .imageScale(.large)
                                .padding()
                                .glassEffect(in: .circle)
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Play video")
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .aspectRatio(displayAspectRatio, contentMode: .fit)
        // Portrait videos use their full height on iPhone; this only stops a
        // tall video from outgrowing a wide iPad column.
        .frame(maxHeight: 720)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The video's own shape, kept within 9:16 portrait and 3:1 landscape.
    private var displayAspectRatio: CGFloat {
        let ratio = video.aspectRatio ?? 16 / 9
        return min(max(ratio, 9 / 16), 3)
    }

    private func play() {
        showVideo = true
    }

    /// Called each time the full-screen viewer opens.
    private func makeFeed() -> any SMVVideoFeed {
        // The overlay looks the post up by ID, so keep what this payload knows.
        XBookmarkStore.shared.recordKnownState(of: tweet)
        return ImmersiveVideoFeed(pinnedTweetID: tweet.id)
    }
}
