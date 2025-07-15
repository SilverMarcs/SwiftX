import SwiftUI

import SwiftUI
import Kingfisher

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            if let banner = user.profileBannerUrl, let url = URL(string: banner) {
                KFImage(url)
                    .downsampling(size: CGSize(width: 800, height: 250))
                    .placeholder {
                        Rectangle()
                            .fill(.background.secondary)
                            .frame(height: 120)
                    }
                    .serialize(as: .JPEG)
                    .fade(duration: 0.1)
                    .resizable()
//                    .frame(height: 200)
                    .aspectRatio(contentMode: .fit)
                    .backgroundExtensionEffect()
            }
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        KFImage(URL(string: user.profileImageUrl))
                            .placeholder {
                                Rectangle()
                                    .fill(.background.secondary)
                            }
                            .downsampling(size: CGSize(width: 400, height: 400))
                            .serialize(as: .JPEG)
                            .fade(duration: 0.1)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.primary, lineWidth: 2)
                            )
                        
                        Spacer()
                        
                        HStack {
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
                        }
                        
                        if let url = URL(string: user.url) {
                            SwiftUI.Link(destination: url) {
                                Label("Profile", systemImage: "bird")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                    
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
                        .padding(.top, -5)
                }
                .padding(.top, (user.profileBannerUrl == nil) ? 0 : -20)
                
                
                Text(user.rawDescription)
                    .font(.callout)
                    .lineLimit(3)
                
                VStack(alignment: .leading, spacing: 10) {
                    if let location = user.location, !location.isEmpty {
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 24) {
                        Label("\(user.formattedFriendsCount) Following", systemImage: "person.crop.circle.badge.checkmark")
                        Label("\(user.formattedFollowersCount) Followers", systemImage: "person.2.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .ignoresSafeArea(edges: (user.profileBannerUrl == nil) ? .bottom : .top)
        .navigationTitle(user.displayname)
        .toolbarTitleDisplayMode(.inline)
    }
}
