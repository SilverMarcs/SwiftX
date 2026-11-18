//
//  MediaView.swift
//  Birdie
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct MediaView: View {
    let media: Media
    /// The post the media belongs to; seeds the full-screen video feed.
    let tweet: any TweetContentProtocol

    var body: some View {
        if let photos = media.photos, !photos.isEmpty {
            PhotoGalleryView(photos: photos)
        }

        if let videos = media.videos, !videos.isEmpty {
            VideoView(video: videos[0], tweet: tweet)
        }
    }
}
