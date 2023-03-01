//
//  Insights.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

public class Insights: IInsightSection {

    public let sectionName: String
    public let sectionResult: InsightResult

    public init(sectionName: String, sectionResult: InsightResult) {
        self.sectionName = sectionName
        self.sectionResult = sectionResult
    }
}
