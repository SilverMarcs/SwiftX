import SwiftUI

struct TimelineContentView: View {
    let model: TimelineStore

    var body: some View {
        if !model.entries.isEmpty, let error = model.error {
            Text("\(error) Pull down to try again.").foregroundStyle(.secondary)
        }
        ForEach(model.entries) { entry in
            TimelineRowView(entry: entry)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.visible, edges: .bottom)
                .listRowSeparator(.hidden, edges: .top)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        }
        if !model.entries.isEmpty || model.nextCursor != nil { TimelineFooterView(model: model) }
    }
}
