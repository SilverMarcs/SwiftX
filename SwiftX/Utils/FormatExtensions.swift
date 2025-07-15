//
//  FormatExtensions.swift
//  SwiftX
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

extension Int {
    /// Formats a count with K/M suffixes for readability
    /// Examples: 1000 -> "1.0K", 1500000 -> "1.5M"
    func formattedCount() -> String {
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

extension String {
    /// Formats a date string to relative time format
    /// Examples: "2h", "3d", "now"
    static let backupFormatter = DateFormatter()
    static let iso8601Formatter = ISO8601DateFormatter()
    
    func formattedRelativeDate() -> String {
        Self.iso8601Formatter.formatOptions = [.withInternetDateTime]
        
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
        
        // Fallback formatter

        Self.backupFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        if let date = Self.backupFormatter.date(from: self) {
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

extension String {
    static func parseContent(_ content: String) -> String {
        // Regular expression pattern to match Twitter's t.co links at the end of the string
        let pattern = "\\s+https://t\\.co/[a-zA-Z0-9]+$"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(content.startIndex..., in: content)
            
            // Replace the matched pattern with empty string
            let parsedContent = regex.stringByReplacingMatches(
                in: content,
                options: [],
                range: range,
                withTemplate: ""
            )
            
            return parsedContent.trimmingCharacters(in: .whitespaces)
        }
        
        return content
    }
}
