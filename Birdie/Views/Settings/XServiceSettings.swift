import SwiftUI

struct XServiceSettings: View {
    var body: some View {
        Section("Account") {
            NavigationLink { XServiceSettingsView() } label: { Label("X session", systemImage: "key") }
        }
    }
}
