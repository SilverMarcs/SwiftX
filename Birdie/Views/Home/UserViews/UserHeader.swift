import SwiftUI
import SwiftMediaViewer

struct UserHeader: View {
    let user: User

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let url = user.avatarURL {
                CachedAsyncImage(url: url, targetSize: 300)
                    .frame(width: 45, height: 45)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(user.name).font(.headline).lineLimit(1)
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(user.isLegacyVerified ? .yellow : .blue)
                            .font(.caption)
                            .accessibilityLabel("Verified")
                    }
                }
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(.rect)
    }
}
