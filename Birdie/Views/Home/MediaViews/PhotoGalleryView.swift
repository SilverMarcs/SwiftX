import SwiftUI
import SwiftMediaViewer

struct PhotoGalleryView: View {
    let photos: [Photo]

    var body: some View {
        SMVGallery(images: photos.compactMap { URL(string: $0.url) }, targetSize: 1000)
    }
}
