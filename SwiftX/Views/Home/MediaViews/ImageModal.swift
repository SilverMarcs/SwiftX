//
//  ImageModal.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Kingfisher

struct ImageModal: View {
    let images: [String]
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    @State private var currentIndex: Int = 0
    
    private var sourceID: String {
        guard currentIndex < images.count else { return images.first ?? "" }
        return images[currentIndex]
    }
    
    init(images: [String], startIndex: Int = 0) {
        self.images = images
        self._currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, imageURL in
                KFImage(URL(string: imageURL))
                    .placeholder {
                        Rectangle()
                            .fill(.background.secondary)
                    }
                    .downsampling(size: CGSize(width: 1000, height: 1000))
                    .serialize(as: .JPEG)
                    .fade(duration: 0.1)
//                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tag(index)
            }
        }
        .ignoresSafeArea()
        .tabViewStyle(.page)
        .navigationTransition(.zoom(sourceID: sourceID, in: imageNS ?? fallbackNS))
    }
}
