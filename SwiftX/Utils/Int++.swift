//
//  Int++.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

extension Int {
    var formatCount: String {
        if self >= 1_000_000 {
            let divided = Double(self) / 1_000_000
            return String(format: "%.1fM", divided)
        } else if self >= 1_000 {
            let divided = Double(self) / 1_000
            return String(format: "%.1fK", divided)
        }
        return String(self)
    }
}
