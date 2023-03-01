//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

public protocol IInsightSection {

    /// The name of the smart insight.
    var sectionName: String { get }

    /// The result of this insight, see `InsightResult`.
    var sectionResult: InsightResult { get }

}
