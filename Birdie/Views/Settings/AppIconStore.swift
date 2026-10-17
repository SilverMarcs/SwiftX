#if os(iOS)
import Observation
import UIKit

@MainActor
@Observable
final class AppIconStore {
    private(set) var currentIconName = UIApplication.shared.alternateIconName
    private(set) var isChangingIcon = false
    private(set) var errorMessage = ""
    var showingError = false

    static var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    func refresh() {
        currentIconName = UIApplication.shared.alternateIconName
    }

    func select(_ option: AppIconOption) async {
        guard Self.supportsAlternateIcons,
              !isChangingIcon,
              currentIconName != option.alternateIconName else { return }

        isChangingIcon = true
        defer { isChangingIcon = false }

        do {
            try await UIApplication.shared.setAlternateIconName(option.alternateIconName)
            refresh()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
#endif
