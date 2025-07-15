//
//  Environment++.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var imageNS: Namespace.ID?
    @Entry var videoNS: Namespace.ID?
    @Entry var appendToPath: ((any Hashable) -> Void) = { _ in
        print("No path append handler provided")
    }
}
