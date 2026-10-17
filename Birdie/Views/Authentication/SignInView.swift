import SwiftUI
import WebKit

struct SignInView: View {
    @State private var controller = XLoginController()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WebView(controller.page)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)
                    .overlay(alignment: .top) {
                        if controller.page.isLoading {
                            ProgressView(value: controller.page.estimatedProgress)
                                .progressViewStyle(.linear)
                        }
                    }
                SignInStatusView(controller: controller)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .navigationTitle("Sign in to X")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        controller.stop()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise", action: controller.reload)
                        .disabled(controller.isValidating)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, idealWidth: 600, minHeight: 600, idealHeight: 720)
        #else
        .presentationDetents([.large])
        #endif
        .task { controller.start() }
        .onDisappear { controller.stop() }
        .onChange(of: controller.didSignIn) {
            if controller.didSignIn { dismiss() }
        }
    }
}
