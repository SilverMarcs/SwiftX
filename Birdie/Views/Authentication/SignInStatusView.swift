import SwiftUI

struct SignInStatusView: View {
    let controller: XLoginController

    var body: some View {
        if controller.isValidating {
            HStack {
                ProgressView()
                Text("Finishing sign-in…")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.bar)
        } else if let error = controller.errorMessage {
            VStack {
                Text(controller.errorTitle).bold()
                Text(error).font(.callout)
                Button("Try Again", systemImage: "arrow.clockwise", action: controller.retry)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.bar)
        }
    }
}
