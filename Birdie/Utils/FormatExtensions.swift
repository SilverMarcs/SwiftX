//
//  FormatExtensions.swift
//  Birdie
//
//  Created by Zabir Raihan on 14/07/2025.
//

import Foundation

extension String {
    nonisolated static func parseContent(_ content: String) -> String {
        // First, decode HTML entities
        let decodedContent = content.decodingHTMLEntities()
        
        // Regular expression pattern to match Twitter's t.co links at the end of the string
        let pattern = "\\s+https://t\\.co/[a-zA-Z0-9]+$"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(decodedContent.startIndex..., in: decodedContent)
            
            // Replace the matched pattern with empty string
            let parsedContent = regex.stringByReplacingMatches(
                in: decodedContent,
                options: [],
                range: range,
                withTemplate: ""
            )
            
            return parsedContent.trimmingCharacters(in: .whitespaces)
        }
        
        return decodedContent
    }
    
    /// Decodes HTML entities in a string (e.g., &amp; -> &, &lt; -> <)
    nonisolated func decodingHTMLEntities() -> String {
        var result = self
        
        // Common HTML entities
        let entities: [(String, String)] = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&apos;", "'"),
            ("&#39;", "'"),
            ("&nbsp;", " "),
            ("&#x27;", "'"),
            ("&#x2F;", "/"),
            ("&#34;", "\""),
            ("&#60;", "<"),
            ("&#62;", ">"),
            ("&#38;", "&"),
        ]
        
        for (entity, replacement) in entities {
            result = result.replacing(entity, with: replacement)
        }
        
        return result
    }
}
