import SwiftUI
import SwiftMediaViewer

struct UserProfileHeader: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Banner Image Section + Profile Image + Action buttons
            VStack(alignment: .leading, spacing: 0) {
                if let url = user.bannerURL {
                    CachedAsyncImage(url: url, targetSize: 300)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 10))
                }

                HStack(alignment: .bottom) {
                    CachedAsyncImage(url: user.avatarURL, targetSize: 300)
                        .frame(width: 80, height: 80)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(.primary, lineWidth: 2)
                        )

                    Spacer()

                    if !user.links.isEmpty {
                        Menu {
                            ForEach(user.links, id: \.url) { link in
                                SwiftUI.Link(destination: link.url) {
                                    Label(link.label, systemImage: "link")
                                }
                            }
                        } label: {
                            Label("Links", systemImage: "link")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderless)
                        .padding(10)
                        .glassEffect()
                    }

                    if let url = user.webURL {
                        SwiftUI.Link(destination: url) {
                            Label("Profile", systemImage: "bird")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
                .padding(.top, -28)
            }

            // User Info Section
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(user.name)
                            .font(.title2.bold())

                        Group {
                            if user.isLegacyVerified {
                                Label("Verified", systemImage: "checkmark.seal.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            } else if user.isVerified {
                                Label("Blue Verified", systemImage: "checkmark.seal.fill")
                                    .foregroundStyle(.blue)
                                    .font(.caption)
                            }
                        }
                        .imageScale(.large)
                        .labelStyle(.iconOnly)

                        Spacer()
                    }

                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(user.bio ?? "")
                    .font(.callout)
                    .lineLimit(2)

                // Location and Stats
                VStack(alignment: .leading, spacing: 5) {
                    if let location = user.location, !location.isEmpty {
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }

                    HStack(spacing: 24) {
                        Label {
                            Text("\(user.followingCount ?? 0, format: .number.notation(.compactName)) Following")
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                        }

                        Label {
                            Text("\(user.followersCount ?? 0, format: .number.notation(.compactName)) Followers")
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "person.2.fill")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .labelStyle(CustomLabelStyle())
            }
        }
        .listRowSeparator(.hidden, edges: .top)
        .listRowSeparator(.visible, edges: .bottom)
        .padding(.top, user.bannerURL == nil ? 15 : -15)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .frame(maxWidth: 800)
        .frame(maxWidth: .infinity)
    }
}
