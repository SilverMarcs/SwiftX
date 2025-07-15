import SwiftUI
import Kingfisher

struct GalleryKFImage: View {
    let url: String

    var body: some View {
        KFImage(URL(string: url))
            .placeholder {
                Rectangle()
                    .fill(.background.secondary)
                    .overlay { ProgressView() }
            }
            .downsampling(size: CGSize(width: 1000, height: 1000))
            .serialize(as: .JPEG)
            .fade(duration: 0.1)
            .resizable()
    }
}
