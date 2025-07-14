//
//  HomeTab.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

struct HomeTab: View {
    @State var path: NavigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .environmentActions(path: $path)
                .navigationDestinations(path: $path)
        }
    }
}

#Preview {
    HomeTab()
}
