import SwiftUI

/// The X accounts section of Settings: switch, add, re-authenticate and remove accounts.
struct XAccountSettingsView: View {
    @State private var signIn: XAccountSignIn?
    @State private var accountToRemove: XAccount?
    @State private var errorMessage: String?
    private let session = XSessionStore.shared

    var body: some View {
        Section {
            ForEach(session.accounts, id: \.id) { account in
                XAccountRowView(account: account) { select(account) }
            }
            .onDelete(perform: confirmRemoval)

            // Presentations hang off this one row: on a Form section they would be
            // copied to every row, presenting the same sign-in page more than once.
            Button("Add Account", systemImage: "plus.circle", action: addAccount)
                .sheet(item: $signIn) { request in
                    SignInView(activatesAccount: request.activatesAccount)
                }
                .alert("Remove Account?", isPresented: removalBinding, presenting: accountToRemove) { account in
                    Button("Remove", role: .destructive) { remove(account) }
                    Button("Cancel", role: .cancel) { }
                } message: { account in
                    Text("@\(account.username) will be signed out of Birdie. Your X account isn't affected.")
                }
                .alert("Couldn't Update Accounts", isPresented: errorBinding) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage ?? "Please try again.")
                }
        } header: {
            Text(session.accounts.count > 1 ? "X Accounts" : "X Account")
        } footer: {
            if session.accounts.isEmpty {
                Text("Sign in to see posts from the people you follow.")
            } else if session.accounts.count > 1 {
                Text("Tap an account to switch to it. Swipe to remove one from Birdie.")
            }
        }
    }

    private var removalBinding: Binding<Bool> {
        Binding { accountToRemove != nil } set: { if !$0 { accountToRemove = nil } }
    }

    private var errorBinding: Binding<Bool> {
        Binding { errorMessage != nil } set: { if !$0 { errorMessage = nil } }
    }

    private func addAccount() {
        // The first account becomes active regardless; later ones leave the current one active.
        signIn = XAccountSignIn(activatesAccount: false)
    }

    private func select(_ account: XAccount) {
        if session.needsSignIn(accountID: account.id) {
            signIn = XAccountSignIn(activatesAccount: true)
            return
        }
        do {
            try session.switchAccount(to: account.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func confirmRemoval(at offsets: IndexSet) {
        guard let index = offsets.first, session.accounts.indices.contains(index) else { return }
        accountToRemove = session.accounts[index]
    }

    private func remove(_ account: XAccount) {
        do {
            try session.removeAccount(id: account.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
