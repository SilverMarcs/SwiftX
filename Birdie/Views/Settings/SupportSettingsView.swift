import SwiftUI

struct SupportSettingsView: View {
    private let supportURL = URL(string: "https://appstore-support.vercel.app/birdie")
    private let privacyURL = URL(string: "https://appstore-support.vercel.app/birdie/privacy")

    var body: some View {
        Section("About Birdie") {
            if let supportURL {
                SwiftUI.Link(destination: supportURL) {
                    Label("Support", systemImage: "questionmark.circle")
                }
            }

            if let privacyURL {
                SwiftUI.Link(destination: privacyURL) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
        }
    }
}
