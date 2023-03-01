//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

extension HTML {
    func linesForCSSClass(_ htmlClass: LoggableCSSClass) -> [String] {
        components(separatedBy: .newlines)
            .filter { htmlLine in
                htmlLine.hasPrefix("<p class=\"\(htmlClass.rawValue)\">")
            }
    }
}

public extension HTML {
    var errorLogs: [String] { linesForCSSClass(.error) }
    var debugLogs: [String] { linesForCSSClass(.debug) }
    var systemLogs: [String] { linesForCSSClass(.system) }
}
