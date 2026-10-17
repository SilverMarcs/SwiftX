import SwiftUI

struct ExpandableText: View {
    let text: String
    var maxCharacters = 400
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(displayedText)

            if text.count > maxCharacters {
                Button(isExpanded ? "Show Less" : "Show More") { isExpanded.toggle() }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
            }
        }
    }

    private var displayedText: String {
        if !isExpanded && text.count > maxCharacters { return String(text.prefix(maxCharacters)) }
        return text
    }
}
