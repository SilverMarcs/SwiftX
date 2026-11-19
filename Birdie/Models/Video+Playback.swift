import Foundation

extension Video {
    /// The variant Birdie plays: X's adaptive HLS stream, which the player
    /// switches up or down with the network, else the highest-bitrate MP4.
    var playbackVariant: VideoVariant? {
        let hls = variants.first { $0.contentType == "application/x-mpegURL" }
        let mp4 = variants.filter { $0.contentType == "video/mp4" }.max { ($0.bitrate ?? 0) < ($1.bitrate ?? 0) }
        return hls ?? mp4 ?? variants.first
    }

    var playbackURL: URL? {
        playbackVariant.flatMap { URL(string: $0.url) }
    }
}
