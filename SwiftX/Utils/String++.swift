//
//  String++.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

extension String {
    func formatDate() -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: self) {
            let now = Date()
            let timeInterval = now.timeIntervalSince(date)
            
            if timeInterval < 60 {
                return "now"
            } else if timeInterval < 3600 {
                return "\(Int(timeInterval / 60))m"
            } else if timeInterval < 86400 {
                return "\(Int(timeInterval / 3600))h"
            } else {
                return "\(Int(timeInterval / 86400))d"
            }
        }
        return ""
    }
}

