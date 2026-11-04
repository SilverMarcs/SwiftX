import SwiftUI
import SwiftMediaViewer

/// A tweet's photos: the first one large, with up to three thumbnails of the
/// rest beneath it. Tapping any photo opens the fullscreen viewer on the whole set.
struct PhotoGalleryView: View {
    let photos: [Photo]

    /// How many photos after the first get a thumbnail.
    private static let maxThumbnailCount = 3

    var body: some View {
        let urls = photos.compactMap { URL(string: $0.url) }
        let thumbnailIndices = urls.indices.dropFirst().prefix(Self.maxThumbnailCount)
        let hiddenCount = urls.count - 1 - thumbnailIndices.count

        SMVGallery(images: urls, targetSize: 1000) {
            VStack(alignment: .leading, spacing: 8) {
                if let firstURL = urls.first {
                    SMVGalleryItem(index: 0) {
                        CachedAsyncImage(url: firstURL, targetSize: 1000)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }

                if !thumbnailIndices.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(thumbnailIndices, id: \.self) { index in
                            SMVGalleryItem(index: index) {
                                PhotoGalleryThumbnail(
                                    url: urls[index],
                                    hiddenCount: index == thumbnailIndices.last ? hiddenCount : 0
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
