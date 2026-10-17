import SwiftUI
import SwiftMediaViewer

struct UserProfileHeaderView: View {
    let store: XProfileStore
    let toggleFollowing: () -> Void
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        VStack(alignment: .leading) {
            UserProfileBannerView(imageURL: store.user.profileBannerUrl)

            HStack(alignment: .bottom) {
                if let url = URL(string: store.user.profileImageUrl) {
                    CachedAsyncImage(url: url, targetSize: Int((80 * displayScale).rounded(.up)))
                        .frame(width: 80, height: 80)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(.circle)
                        .overlay { Circle().stroke(.primary, lineWidth: 2) }
                        .accessibilityHidden(true)
                }

                Spacer()

                if !store.user.descriptionLinks.isEmpty {
                    Menu("Links", systemImage: "link") {
                        ForEach(store.user.descriptionLinks, id: \.url) { link in
                            if let url = URL(string: link.url) {
                                SwiftUI.Link(destination: url) {
                                    Label(link.text ?? "Link", systemImage: "link")
                                }
                            }
                        }
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .padding(10)
                    .glassEffect()
                }

                if !store.isOwnAccount {
                    Button(action: toggleFollowing) {
                        HStack {
                            if store.isMutating || (store.isLoading && store.relationship == nil) {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(store.followButtonTitle)
                        }
                    }
                    .buttonStyle(.borderless)
                    .padding(10)
                    .glassEffect()
                    .disabled(!store.canChangeFollowing)
                    .accessibilityLabel(store.followAccessibilityLabel)
                }
            }
            .padding(.top, -28)

            VStack(alignment: .leading) {
                HStack {
                    Text(store.user.displayname)
                        .font(.title2.bold())
                    if store.user.verified == true {
                        Label("Verified", systemImage: "checkmark.seal.fill")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.yellow)
                    } else if store.user.blue == true {
                        Label("Blue Verified", systemImage: "checkmark.seal.fill")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.blue)
                    }
                }
                Text("@\(store.user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !store.user.rawDescription.isEmpty {
                Text(store.user.rawDescription)
                    .font(.callout)
                    .textSelection(.enabled)
            }

            if let location = store.user.location, !location.isEmpty {
                Label {
                    Text(location)
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                        .scaleEffect(0.8)
                }
                .font(.subheadline)
                .foregroundStyle(.green)
                .labelIconToTitleSpacing(2)
            }

            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("\(store.user.friendsCount, format: .number.notation(.compactName)) Following")
                    Text("\(store.user.followersCount, format: .number.notation(.compactName)) Followers")
                }
                VStack(alignment: .leading) {
                    Text("\(store.user.friendsCount, format: .number.notation(.compactName)) Following")
                    Text("\(store.user.followersCount, format: .number.notation(.compactName)) Followers")
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
        }
    }
}
