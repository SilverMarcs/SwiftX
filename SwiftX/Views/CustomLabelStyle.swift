//
//  CustomLabelStyle.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import SwiftUI

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon
                .font(.subheadline)
            
            configuration.title
                .font(.callout)
                .fontWeight(.medium)
        }
    }
}

struct RetweetLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon
                .font(.caption)
                .fontWeight(.semibold)
            
            configuration.title
                .font(.callout)
        }
        .foregroundStyle(.secondary)
    }
}
