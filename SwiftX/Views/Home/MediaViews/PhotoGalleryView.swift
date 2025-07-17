import SwiftUI
import CachedAsyncImage

struct PhotoGalleryView: View {
    let photos: [Photo]
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    @Environment(\.appendToPath) private var appendToPath

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let first = photos.first {
                Button {
                    appendToPath(ImageModalData(images: photos.map { $0.url }, startIndex: 0))
                } label: {
                    CachedAsyncImage(url: URL(string: first.url)!, targetSize: CGSize(width: 500, height: 500))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 325, height: 300)
                        .clipShape(.rect(cornerRadius: 10))
                        .matchedTransitionSource(id: first.url, in: imageNS ?? fallbackNS)
                }
                .buttonStyle(.plain)
            }

            if photos.count > 1 {
                HStack(spacing: 8) {
                    ForEach(Array(photos.enumerated()).dropFirst().prefix(3), id: \.offset) { idx, photo in
                        Button {
                            appendToPath(ImageModalData(images: photos.map { $0.url }, startIndex: idx))
                        } label: {
                            CachedAsyncImage(url: URL(string: photo.url)!, targetSize: CGSize(width: 500, height: 500))
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(.rect(cornerRadius: 8))
                                .matchedTransitionSource(id: photo.url, in: imageNS ?? fallbackNS)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
