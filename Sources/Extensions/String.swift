//
//  String.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

extension String: HTMLEncoding, HTMLGenerator {
    /// Encodes entities to be displayed correctly in the final HTML report.
    func addingHTMLEncoding() -> HTML {
        return replacingOccurrences(of: "<", with: "&lt;")
                   .replacingOccurrences(of: ">", with: "&gt;")
    }

    public func html() -> HTML {
        return self
    }

    var anchor: String {
        return lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
