import SwiftUI

struct XAccountSettingsView: View {
    @State private var showingSignIn = false
    @State private var isSigningOut = false
    private let session = XSessionStore.shared

    var body: some View {
        Section("X Account") {
            if let account = session.account {
                HStack {
                    AsyncImage(url: account.profileImageURL.flatMap(URL.init(string:))) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill").foregroundStyle(.secondary)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(.circle)
                    .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(account.displayName).bold()
                        Text("@\(account.username)").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: signOut)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .disabled(isSigningOut || session.isSigningOut)
                }
            } else {
                Text(session.needsSignIn ? "Your X session has expired. Sign in again to continue." : "Sign in to see posts from the people you follow.")
                    .foregroundStyle(.secondary)
                Button("Sign in to X", systemImage: "person.crop.circle") { showingSignIn = true }
                    .disabled(isSigningOut || session.isSigningOut)
            }
        }
        .sheet(isPresented: $showingSignIn) { SignInView() }
    }

    private func signOut() {
        isSigningOut = true
        Task {
            await session.signOut()
            isSigningOut = false
        }
    }
}
