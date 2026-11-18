import SwiftUI

/// One signed-in account. Tapping it switches to it, or signs in again when its session expired.
struct XAccountRowView: View {
    let account: XAccount
    let action: () -> Void
    private let session = XSessionStore.shared

    var body: some View {
        let isActive = session.activeAccountID == account.id
        let needsSignIn = session.needsSignIn(accountID: account.id)
        Button(action: action) {
            HStack {
                AsyncImage(url: account.profileImageURL.flatMap(URL.init(string:))) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(.secondary)
                }
                .frame(width: 40, height: 40)
                .clipShape(.circle)
                .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(account.displayName)
                        .bold()
                    Text(needsSignIn ? "Session expired. Tap to sign in again." : "@\(account.username)")
                        .font(.subheadline)
                        .foregroundStyle(needsSignIn ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark")
                        .bold()
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}
