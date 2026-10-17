import SwiftUI
import SwiftMediaViewer

struct UserProfileBannerView: View {
    let imageURL: String?

    var body: some View {
        Rectangle()
            .fill(.quaternary)
            .aspectRatio(3, contentMode: .fit)
            .overlay {
                if let imageURL, let url = URL(string: imageURL) {
                    CachedAsyncImage(url: url, targetSize: 800)
                        .aspectRatio(contentMode: .fill)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            .accessibilityHidden(true)
    }
}
