//
//  AilmentFilter.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

public protocol AilmentFilter {
    /// Filters the input `Diagnostics` value. Can be used to remove sensitive data.
    /// - Parameter diagnostics: The `Diagnostics` value to use for input in the filter.
    /// Returns: Any type of `Diagnostics` but possibly filtered.
    static func filter(_ diagnostics: Ailment) -> Ailment
}
