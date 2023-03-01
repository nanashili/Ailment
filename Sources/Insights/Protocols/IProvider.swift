//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

public protocol SmartInsightsProviding {

    /// Allows parsing the given chapter and read Smart Insights out of it.
    /// - Parameter `chapter`: The `AilmentSector` to use for reading out insights.
    /// - Returns: An collection of smart insights derived from the chapter.
    func smartInsights(for section: AilmentSector) -> [IInsightSection]
}
