import SwiftUI
import Kingfisher

struct UserButton: View {
    let user: User
    @Environment(\.appendToPath) private var appendToPath

    var body: some View {
        Button {
            appendToPath(user)
        } label: {
            HStack(alignment: .center, spacing: 8) {
                KFImage(URL(string: user.profileImageUrl))
                    .placeholder {
                        Rectangle()
                            .fill(.background.secondary)
                    }
                    .downsampling(size: CGSize(width: 400, height: 400))
                    .serialize(as: .JPEG)
                    .fade(duration: 0.1)
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
        }
        .buttonStyle(.plain)
    }
}
