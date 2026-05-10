import SwiftUI

struct XServiceSettings: View {
    var body: some View {
        Section("Account") {
            NavigationLink {
                XServiceSettingsView()
            } label: {
                Label("Authentication", systemImage: "key.fill")
            }
        }
    }
}

struct XServiceSettingsView: View {
    @Bindable private var store = XAuthStore.shared

    var body: some View {
        Form {
            Section {
                TextField("Public List ID", text: $store.listId, prompt: Text("Example: 1661518034639659009"))
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
            } header: {
                Text("List")
            } footer: {
                Text("This is the X List ID — the numeric ID at the end of any `x.com/i/lists/<id>` URL. The Home tab loads tweets from this list.")
            }

            Section {
                TextEditor(text: $store.cookieHeader)
                    .frame(maxHeight: 70)
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
                    .clipShape(.rect(cornerRadius: 10))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Cookie")
            } footer: {
                Text("In a logged-in browser (X.com), open DevTools → Network, click any `i/api/graphql` request, and copy the `Cookie` request header value. You can paste either the full `Cookie: ...` line or just the value.")
            }

            Section {
                TextField("Authorization", text: $store.authorizationBearer, prompt: Text("Bearer ..."))
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()

                TextField("User-Agent", text: $store.userAgent, prompt: Text("Mozilla/5.0 ..."))
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()

                TextField("Guest token", text: $store.guestToken, prompt: Text("Optional"))
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
            } header: {
                Text("Headers")
            } footer: {
                Text("Grab these from the same `i/api/graphql` request in DevTools: copy the `authorization` header (with the `Bearer ` prefix) and the `user-agent` header. Guest token is optional — leave empty unless requests fail.")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Authentication")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        XServiceSettingsView()
    }
}
