//
//  ImageModalData.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

struct ImageModalData: Hashable {
    let images: [String]
    let startIndex: Int
    
    init(images: [String], startIndex: Int = 0) {
        self.images = images
        self.startIndex = startIndex
    }
}
