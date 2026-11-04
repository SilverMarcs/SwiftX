import SwiftUI

/// A minimal sheet for posting a text reply to a single post.
struct ReplyComposerView: View {
    let tweet: Tweet
    var onPosted: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isPosting = false
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool

    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            TextField("Post your reply", text: $text, axis: .vertical)
                .focused($isFocused)
                .disabled(isPosting)
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationTitle("Reply to @\(tweet.user.username)")
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark", role: .cancel) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Button("Reply", systemImage: "arrow.up", role: .confirm) {
                                Task { await post() }
                            }
                            .disabled(trimmedText.isEmpty)
                        }
                    }
                }
                .alert("Couldn’t Reply", isPresented: Binding {
                    errorMessage != nil
                } set: { isPresented in
                    if !isPresented { errorMessage = nil }
                }) {
                    Button("OK") {}
                } message: {
                    Text(errorMessage ?? "")
                }
        }
        .interactiveDismissDisabled(isPosting || !trimmedText.isEmpty)
        .onAppear { isFocused = true }
    }

    private func post() async {
        isPosting = true
        defer { isPosting = false }
        do {
            try await XClient.shared.postReply(to: tweet.id, text: trimmedText)
            onPosted()
            dismiss()
        } catch {
            guard !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }
}
