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
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(photos, id: \.url) { photo in
                            AsyncImage(url: URL(string: photo.url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(.gray.opacity(0.3))
                            }
                            .frame(maxHeight: 200)
                            .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                }
            }
            
            if let videos = media.videos, !videos.isEmpty {
                ForEach(videos.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: videos[index].thumbnailUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                            )
                    }
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
