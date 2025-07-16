//
//  MediaView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct MediaView: View {
    let media: Media
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    
    @Environment(\.appendToPath) private var appendToPath

    var body: some View {
        VStack {
            if let photos = media.photos, !photos.isEmpty {
                PhotoGalleryView(photos: photos)
            }

            if let videos = media.videos, !videos.isEmpty {
                VideoView(video: videos[0])
//                if videos.count > 1 {
//                    Text("+\(videos.count - 1)")
//                }
            }
        }
    }
}
