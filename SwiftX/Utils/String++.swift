//
//  String++.swift
//  SwiftX
//
//  Created by Zabir Raihan on 13/07/2025.
//

import SwiftUI

extension String {
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    func formatDate() -> String {
        Self.iso8601Formatter.formatOptions = [.withInternetDateTime] // This is important for your format
        
        if let date = Self.iso8601Formatter.date(from: self) {
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
        
        // If the above fails, try DateFormatter as fallback
        let backupFormatter = DateFormatter()
        backupFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        if let date = backupFormatter.date(from: self) {
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
