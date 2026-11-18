import Foundation

/// A sign-in sheet request from the accounts section.
struct XAccountSignIn: Identifiable {
    let id = UUID()
    /// Whether the account signed in becomes the active one.
    let activatesAccount: Bool
}
