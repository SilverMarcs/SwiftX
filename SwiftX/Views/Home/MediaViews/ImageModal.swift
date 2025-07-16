//
//  ImageModal.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

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
                CachedImageView(url: URL(string: imageURL)!, targetSize: CGSize(width: 500, height: 500))
                    .aspectRatio(contentMode: .fit)
                    .zoomable()
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
