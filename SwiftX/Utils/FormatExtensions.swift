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
