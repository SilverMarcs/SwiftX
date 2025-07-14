import SwiftUI

import SwiftUI
import Kingfisher

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            if let banner = user.profileBannerUrl, let url = URL(string: banner) {
                KFImage(url)
                    .placeholder {
                        Rectangle()
                            .fill(.background.secondary)
                    }
                    .downsampling(size: CGSize(width: 800, height: 250))
                    .serialize(as: .JPEG)
                    .fade(duration: 0.1)
                    .resizable()
                    .frame(height: 200)
                    .aspectRatio(contentMode: .fit)
                    .backgroundExtensionEffect()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    KFImage(URL(string: user.profileImageUrl))
                        .placeholder {
                            Rectangle()
                                .fill(.background.secondary)
                        }
                        .downsampling(size: CGSize(width: 250, height: 250))
                        .serialize(as: .JPEG)
                        .fade(duration: 0.1)
                        .frame(width: 80, height: 80)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.displayname)
                            .font(.title2.bold())
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let location = user.location, !location.isEmpty {
                            Label(location, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if user.verified == true {
                            Label("Verified", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        } else if user.blue == true {
                            Label("Blue Verified", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.caption)
                        }
                    }
                }
                
                Text(user.rawDescription)
                    .font(.body)
                
                HStack(spacing: 24) {
                    Label("\(user.followersCount) Followers", systemImage: "person.2.fill")
                    Label("\(user.friendsCount) Following", systemImage: "person.crop.circle.badge.checkmark")
                    Label("\(user.statusesCount) Tweets", systemImage: "text.bubble.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                if let url = URL(string: user.url) {
                    SwiftUI.Link(destination: url) {
                        Label("Profile", systemImage: "link")
                    }
                }
            }
                .scenePadding()
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle(user.displayname)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        UserDetailView(user: User(
            id: 1001,
            url: "https://example.com/user/1001",
            username: "techvision",
            displayname: "Tech Vision",
            rawDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            created: "2020-06-15T09:30:00Z",
            followersCount: 15234,
            friendsCount: 892,
            statusesCount: 3456,
            location: "San Francisco, CA",
            profileImageUrl: "https://picsum.photos/seed/user1001/200/200",
            profileBannerUrl: "https://picsum.photos/seed/banner1001/1500/500",
            verified: true,
            blue: true,
            descriptionLinks: [
                Link(url: "https://techvision.blog", text: nil, tcourl: nil),
                Link(url: "https://github.com/techvision", text: nil, tcourl: nil)
            ],
            pinnedIds: [123456, 123457, 123458]
        ),)
    }
}
