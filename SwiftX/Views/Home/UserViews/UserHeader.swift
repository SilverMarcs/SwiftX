import SwiftUI
import CachedAsyncImage

struct UserHeader: View {
    let user: User

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            CachedAsyncImage(url: URL(string: user.profileImageUrl)!, targetSize: CGSize(width: 300, height: 300))
                .frame(width: 45, height: 45)
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())

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
