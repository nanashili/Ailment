//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

extension KeyValuePairs: HTMLGenerator where Key == String, Value == String {
    public func html() -> HTML {
        var html = "<table>"
        
        for (key, value) in self {
            html += "<tr><th>\(key)</th><td>\(value)</td></tr>"
        }
        
        html += "</table>"
        
        return html
    }
}
