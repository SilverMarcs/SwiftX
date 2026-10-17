import Foundation

enum AppIconOption: String, CaseIterable, Identifiable {
    case standard
    case classic

    var id: Self { self }

    var displayName: LocalizedStringResource {
        switch self {
        case .standard: "Default"
        case .classic: "Classic"
        }
    }

    var alternateIconName: String? {
        switch self {
        case .standard: nil
        case .classic: "AppIcon"
        }
    }
}
