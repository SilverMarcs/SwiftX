//
//  UniversalProgressView.swift
//  SwiftX
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct UniversalProgressView: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .listRowSeparator(.hidden)
    }
}

#Preview {
    UniversalProgressView()
}
