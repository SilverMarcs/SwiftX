import SwiftUI

struct TimelineFeedView: View {
    let model: TimelineStore

    var body: some View {
        List {
            TimelineContentView(model: model)
        }
        .listStyle(.plain)
    }
}
