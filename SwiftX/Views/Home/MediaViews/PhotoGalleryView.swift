import SwiftUI
import SwiftMediaViewer

struct PhotoGalleryView: View {
    let photos: [Photo]

    var body: some View {
        SMVImage(urls: photos.map { $0.url }, targetSize: 600)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .clipped()
    }
}
