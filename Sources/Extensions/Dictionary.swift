//
//  Dictionary.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

extension Dictionary: HTMLGenerator where Key == String {
    public func html() -> HTML {
        var html = "<table>"

        for (key, value) in self.sorted(by: { $0.0 < $1.0 }) {
            html += "<tr><th>\(key.description)</th><td>\(value)</td></tr>"
        }

        html += "</table>"

        return html
    }
}
