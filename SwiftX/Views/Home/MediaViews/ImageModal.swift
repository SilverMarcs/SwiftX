//
//  ImageModal.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI
import Kingfisher

struct ImageModal: View {
    let data: ImageModalData
    @Environment(\.imageNS) private var imageNS
    @Namespace private var fallbackNS
    @State private var currentIndex: Int = 0
    
    private var sourceID: String {
        guard currentIndex < data.images.count else { return data.images.first ?? "" }
        return data.images[currentIndex]
    }
    
    init(data: ImageModalData) {
        self.data = data
        self._currentIndex = State(initialValue: data.startIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(data.images.enumerated()), id: \.offset) { index, imageURL in
                KFImage(URL(string: imageURL))
                    .placeholder {
                        Rectangle()
                            .fill(.background.secondary)
                    }
                    .downsampling(size: CGSize(width: 1000, height: 1000))
                    .serialize(as: .JPEG)
                    .fade(duration: 0.1)
                    .resizable()
                    .zoomable()
                    .aspectRatio(contentMode: .fit)
                    .tag(index)
            }
        }
        .ignoresSafeArea()
        #if !os(macOS)
        .tabViewStyle(.page)
        .navigationTransition(.zoom(sourceID: sourceID, in: imageNS ?? fallbackNS))
        #endif
    }
}
