//
//  HTMLGenerator.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

public typealias HTML = String

public protocol HTMLGenerator {
    func html() -> HTML
}

public protocol HTMLFormatting {
    static func format(_ diagnostics: Ailment) -> HTML
}
