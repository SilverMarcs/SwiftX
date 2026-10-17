#if os(iOS)
import SwiftUI

struct AppIconPicker: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = AppIconStore()

    var body: some View {
        Form {
            Section {
                ForEach(AppIconOption.allCases) { option in
                    let isSelected: Bool = store.currentIconName == option.alternateIconName

                    Button {
                        Task { await store.select(option) }
                    } label: {
                        HStack {
                            Text(option.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityAddTraits(
                        isSelected ? .isSelected : []
                    )
                }
            }
            .disabled(store.isChangingIcon || !AppIconStore.supportsAlternateIcons)
        }
        .formStyle(.grouped)
        .navigationTitle("App Icon")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                store.refresh()
            }
        }
        .alert("Unable to Change App Icon", isPresented: $store.showingError) {
        } message: {
            Text(store.errorMessage)
        }
    }
}
#endif
