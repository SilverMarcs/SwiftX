import SwiftUI

struct FeedErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Label(message, systemImage: "exclamationmark.triangle")
                .font(.subheadline)
            Button("Try again", systemImage: "arrow.clockwise", action: retry)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 12))
    }
}
