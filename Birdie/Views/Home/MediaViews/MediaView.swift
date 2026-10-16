import SwiftUI

struct MediaView: View {
    let media: Media

    var body: some View {
        if !media.photos.isEmpty { PhotoGalleryView(photos: media.photos) }
        ForEach(media.videos, id: \.thumbnailUrl) { video in VideoView(video: video) }
    }
}
