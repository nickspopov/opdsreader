//
//  View+Extension.swift
//  opdsreader
//
//  Created by Николай Попов on 13.01.2023.
//

import SwiftUI

import SwiftUI

extension View {
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
}

extension String {
    /// Some OPDS catalogs send HTML in <content>; render it as plain text.
    func strippingHTML() -> String {
        let withBreaks = replacingOccurrences(of: "(?i)</p>|<br ?/?>", with: "\n", options: .regularExpression)
        let noTags = withBreaks.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return noTags
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
