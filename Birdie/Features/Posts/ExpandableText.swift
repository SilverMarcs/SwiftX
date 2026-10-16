import SwiftUI

struct ExpandableText: View {
    let text: String
    var maxCharacters = 400
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(isExpanded ? text : String(text.prefix(maxCharacters)))
                .textSelection(.enabled)
                .lineSpacing(2)

            if text.count > maxCharacters {
                Button(isExpanded ? "Show Less" : "Show More") { isExpanded.toggle() }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
            }
        }
    }
}
