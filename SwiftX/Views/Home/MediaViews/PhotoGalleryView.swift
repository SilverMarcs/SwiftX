import SwiftUI
import SwiftMediaViewer

struct PhotoGalleryView: View {
    let photos: [Photo]

    var body: some View {
        SMVGallery(
            images: photos.map { $0.url },
            layout: .mainWithThumbs(thumbSize: 80, maxThumbs: 3),
            targetSize: 600
        )
    }
}
