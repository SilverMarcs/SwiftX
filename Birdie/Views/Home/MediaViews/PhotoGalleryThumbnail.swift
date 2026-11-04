import SwiftUI
import SwiftMediaViewer

/// A square thumbnail in ``PhotoGalleryView``'s row. When photos remain beyond
/// the row, the last thumbnail is dimmed and shows how many.
struct PhotoGalleryThumbnail: View {
    let url: URL
    /// Photos not shown in the row; zero shows no overlay.
    let hiddenCount: Int

    var body: some View {
        CachedAsyncImage(url: url, targetSize: 1000)
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                if hiddenCount > 0 {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.black.opacity(0.6))
                        .overlay {
                            Text("+\(hiddenCount)")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                }
            }
    }
}
