import SwiftUI

struct PostHeader: View {
    @Environment(NavigationPathManager.self) private var navigation
    let tweet: Post

    var body: some View {
        HStack {
            Button {
                navigation.path.append(NavigationDestination.userDetail(tweet.user))
            } label: {
                UserHeader(user: tweet.user)
            }
            .buttonStyle(.plain)
            Spacer()
            if let date = tweet.date {
                Text(date, format: .relative(presentation: .named, unitsStyle: .narrow))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .help(date.formatted())
            }
        }
    }
}
