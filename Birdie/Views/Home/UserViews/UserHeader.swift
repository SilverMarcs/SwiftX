import SwiftUI
import SwiftMediaViewer

struct UserHeader: View {
    let user: User
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Group {
                if let url = URL(string: user.profileImageUrl) {
                    CachedAsyncImage(url: url, targetSize: Int((45 * displayScale).rounded(.up)))
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 45, height: 45)
            .clipShape(.circle)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(user.displayname)
                        .font(.headline)
                        .lineLimit(1)

                    if user.verified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    } else if user.blue == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.blue)
                            .font(.caption)
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
