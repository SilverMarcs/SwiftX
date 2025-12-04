import SwiftUI
import SwiftMediaViewer

struct UserDetailView: View {
    let user: User
    @State private var tweets: [Tweet] = []
    @State private var isLoading = false

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 15) {
                // Banner Image Section + Profile Image + Action buttons
                VStack(alignment: .leading, spacing: 0) {
                    if let banner = user.profileBannerUrl, let url = URL(string: banner) {
                        CachedAsyncImage(url: url, targetSize: 300)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    
                    HStack(alignment: .bottom) {
                        CachedAsyncImage(url: URL(string: user.profileImageUrl)!, targetSize: 300)
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(.primary, lineWidth: 2)
                            )
                        
                        Spacer()
                        
                        if !user.descriptionLinks.isEmpty {
                            Menu {
                                ForEach(user.descriptionLinks, id: \.url) { link in
                                    SwiftUI.Link(destination: URL(string: link.url)!) {
                                        Label(link.text ?? "Link", systemImage: "link")
                                    }
                                }
                            } label: {
                                Label("Links", systemImage: "link")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.borderless)
                            .padding(10)
                            .glassEffect()
                        }
                        
                        if let url = URL(string: user.url) {
                            SwiftUI.Link(destination: url) {
                                Label("Profile", systemImage: "bird")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                    .padding(.top, -28)
                }
                
                // User Info Section
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(user.displayname)
                                .font(.title2.bold())
                            
                            Group {
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
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            
                            Spacer()
                        }
                        
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(user.rawDescription)
                        .font(.callout)
                        .lineLimit(2) // not working
                    
                    // Location and Stats
                    VStack(alignment: .leading, spacing: 5) {
                        if let location = user.location, !location.isEmpty {
                            Label(location, systemImage: "mappin.and.ellipse")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                        
                        HStack(spacing: 24) {
                            Label {
                                Text("\(user.friendsCount, format: .number.notation(.compactName)) Following")
                                    .fontWeight(.semibold)
                            } icon: {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                            }

                            Label {
                                Text("\(user.followersCount, format: .number.notation(.compactName)) Followers")
                                    .fontWeight(.semibold)
                            } icon: {
                                Image(systemName: "person.2.fill")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .labelStyle(CustomLabelStyle())
                }
            }
            .listRowSeparator(.hidden, edges: .top)
            .listRowSeparator(.visible, edges: .bottom)
            .padding(.top, user.profileBannerUrl == nil ? 15 : -15) // Add this line
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            
            // Loading State
            if isLoading {
                UniversalProgressView()
                    .padding(.top, 100)
            }
            
            // Tweets
            TweetItemsView(tweets: tweets)
        }
        .listStyle(.plain)
        .navigationTitle(user.displayname)
        .toolbarTitleDisplayMode(.inline)
        .task {
            if tweets.isEmpty {
                await fetchUserTweets()
            }
        }
        .refreshable {
            await fetchUserTweets()
        }
    }

    private func fetchUserTweets() async {
        isLoading = true
        do {
            let fetchTweets = try await TweetService.fetchUserTweets(userId: user.id, limit: 12)
            tweets = fetchTweets
        } catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }
}
