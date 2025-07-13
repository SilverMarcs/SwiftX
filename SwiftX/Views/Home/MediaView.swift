//
//  MediaView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct MediaView: View {
    let media: Media
    
    var body: some View {
        VStack {
            if let photos = media.photos, !photos.isEmpty {
                AsyncImage(url: URL(string: photos[0].url)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.background.secondary)
                }
                .frame(width: 300, height: 300)
                .clipShape(.rect(cornerRadius: 10))
                
                // Show indicator if there are more photos
                if photos.count > 1 {
                    Text("+\(photos.count - 1)")
                }
            }
            
            if let videos = media.videos, !videos.isEmpty {
                if let videoURL = videos[0].variants.first?.url,
                   let url = URL(string: videoURL) {
                    VideoPlayerView(url: url)
                }
                
                if videos.count > 1 {
                    Text("+\(videos.count - 1)")
                }
            }
        }
    }
}
