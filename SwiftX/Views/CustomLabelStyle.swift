//
//  CustomLabelStyle.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.subheadline)
//                .scaleEffect(0.9)
            
            configuration.title
                .font(.callout)
                .fontWeight(.semibold)
        }
    }
}
