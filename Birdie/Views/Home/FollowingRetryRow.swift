import SwiftUI

struct FollowingRetryRow: View {
    let message: String
    let retry: () async -> Void

    var body: some View {
        VStack {
            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again", systemImage: "arrow.clockwise") {
                Task { await retry() }
            }
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
    }
}
