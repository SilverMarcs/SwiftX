import SwiftUI

/// The Saved tab's filter menu: newest first, or a random order X doesn't offer.
struct SavedPostsOrderMenu: View {
    @Binding var order: SavedPostsOrder
    let onShuffle: () -> Void

    var body: some View {
        Menu {
            Picker("Order", selection: $order) {
                ForEach(SavedPostsOrder.allCases) { option in
                    Label(option.rawValue, systemImage: option.systemImage)
                        .tag(option)
                }
            }

            if order == .shuffled {
                Section {
                    Button("Shuffle Again", systemImage: "shuffle", action: onShuffle)
                }
            }

            SettingsMenuButton()
        } label: {
            Label(order.rawValue, systemImage: "line.3.horizontal.decrease")
        }
        .accessibilityLabel("Order: \(order.rawValue)")
        .sensoryFeedback(.selection, trigger: order)
    }
}
