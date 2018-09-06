//
//  StringExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 27/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation

extension String {
    
    var htmlStripped: String {
        return replace(regex: "<[^>]+>", with: "")
    }
    
    var htmlDecoded: String {
        // http://stackoverflow.com/questions/25607247/how-do-i-decode-html-entities-in-swift
        guard !isEmpty else { return self }
        
        var position = startIndex
        var result = ""
        
        // Mapping from XML/HTML character entity reference to character
        // From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
        let characterEntities: [String: Character] = [
            // XML predefined entities:
            "&quot;": "\"",
            "&amp;": "&",
            "&apos;": "'",
            "&lt;": "<",
            "&gt;": ">",
            "&hellop;": "…",
            
            // HTML character entity references:
            "&nbsp;": "\u{00a0}"
        ]
        
        // ===== Utility functions =====
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string: String, base : Int32) -> Character? {
            let code = UInt32(strtoul(string, nil, base))
            return Character(UnicodeScalar(code)!)
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity: String) -> Character? {
            return entity.hasPrefix("&#x") || entity.hasPrefix("&#X")
                ? decodeNumeric(entity[3...]!, base: 16)
                : entity.hasPrefix("&#")
                ? decodeNumeric(entity[2...]!, base: 10)
                : characterEntities[entity]
        }
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = range(of: "&", range: position..<endIndex) {
            result.append(String(self[position..<ampRange.lowerBound]))
            position = ampRange.lowerBound
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = range(of: ";", range: position..<endIndex) else { break }
            
            let entity = self[position..<semiRange.upperBound]
            position = semiRange.upperBound
            
            if let decoded = decode(String(entity)) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(String(entity))
            }
        }
        
        // Copy remaining characters to result
        result.append(String(self[position..<endIndex]))
        return result
    }
    
    init(htmlEncodedString: String) {
        self.init()
        
        if let attributedString = htmlEncodedString.htmlToAttributedString() {
            self = attributedString.string
        } else {
            self = htmlEncodedString
        }
    }
    
    func htmlToAttributedString() -> NSAttributedString? {
        if let data = self.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html,
                NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.characterEncoding.rawValue): String.Encoding.utf8.rawValue
            ]
            
            if let attributedString = try? NSAttributedString(data:data, options:options, documentAttributes:nil) {
                return attributedString
            }
        }
        
        return nil
    }
    
    func replace(regex: String, with replacement: String, caseSensitive: Bool = false) -> String {
        guard !isEmpty else { return self }
        
        // Determine options
        var options: CompareOptions = [.regularExpression]
        if !caseSensitive {
            options.insert(.caseInsensitive)
        }
        
        return replacingOccurrences(of: regex, with: replacement, options: options)
    }
}

// MARK: - Subscript for ranges
// https://github.com/SwifterSwift/SwifterSwift
public extension String {
    
    /// Safely subscript string with index.
    ///
    /// - Parameter i: index.
    subscript(i: Int) -> String? {
        guard 0..<count ~= i else { return nil }
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    /// Safely subscript string within a half-open range.
    ///
    /// - Parameter range: Half-open range.
    subscript(range: CountableRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex),
            let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex)
            else { return nil }
        
        return String(self[lowerIndex..<upperIndex])
    }
    
    /// Safely subscript string within a closed range.
    ///
    /// - Parameter range: Closed range.
    subscript(range: ClosedRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex),
            let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex)
            else { return nil }
        
        return String(self[lowerIndex..<upperIndex])
    }
    
    /// Safely subscript string from the lower range to the end of the string.
    ///
    /// - Parameter range: A partial interval extending upward from a lower bound that forms a sequence of increasing values..
    subscript(range: CountablePartialRangeFrom<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex)
            else { return nil }
        
        return String(self[lowerIndex..<endIndex])
    }
}
