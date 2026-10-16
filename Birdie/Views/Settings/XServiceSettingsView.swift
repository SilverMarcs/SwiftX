import SwiftUI

struct XServiceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = XAuthStore.shared
    @State private var cookie = ""
    @State private var authorization = ""
    @State private var userAgent = ""
    @State private var error: String?

    var body: some View {
        Form {
            Section {
                SecureField("Cookie", text: $cookie)
                    .autocorrectionDisabled()
                SecureField("Authorization (Bearer …)", text: $authorization)
                    .autocorrectionDisabled()
                TextField("User-Agent (optional)", text: $userAgent)
                    .autocorrectionDisabled()
            } header: {
                Text("X browser session")
            } footer: {
                Text("In your signed-in X browser, open the Network inspector and copy the Cookie and Authorization request headers from a timeline request. The cookie must include auth_token and ct0. Your session is stored in Keychain.")
            }
            #if !os(macOS)
            .textInputAutocapitalization(.never)
            #endif
            Section {
                Label(store.isAuthenticated ? "Session saved" : "Session required", systemImage: store.isAuthenticated ? "checkmark.circle" : "key")
                Text("Home loads your personalized For you feed, including recommendations from accounts you don’t follow.")
                    .foregroundStyle(.secondary)
                if let error { Text(error).foregroundStyle(.red) }
                Button("Save session", systemImage: "key", action: save)
                    .disabled(cookie.isEmpty || authorization.isEmpty)
                if store.isAuthenticated {
                    Button("Sign out of Birdie", role: .destructive, action: signOut)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("X session")
        .task {
            cookie = store.session.cookie
            authorization = store.session.authorization
            userAgent = store.session.userAgent
        }
    }

    private func save() {
        do {
            try store.save(XSession(cookie: cookie, authorization: authorization, userAgent: userAgent))
            dismiss()
        } catch { self.error = error.localizedDescription }
    }

    private func signOut() {
        do { try store.signOut(); cookie = ""; authorization = ""; dismiss() }
        catch { self.error = error.localizedDescription }
    }
}
