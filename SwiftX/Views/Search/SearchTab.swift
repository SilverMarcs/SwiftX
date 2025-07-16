//
//  SearchTab.swift
//  SwiftX
//
//  Created by Zabir Raihan on 16/07/2025.
//

import SwiftUI

struct SearchTab: View {
    @State var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            SearchView()
                .environmentActions(path: $path)
                .navigationDestinations(path: $path)
        }
    }
}
