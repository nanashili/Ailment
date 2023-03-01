//
//  InsightsReporter.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

import Foundation

public enum InsightResult: Equatable {
    case success(message: String)
    case warn(message: String)
    case error(message: String)

    var message: String {
        switch self {
        case .success(let message):
            return "✅ \(message)"
        case .warn(let message):
            return "⚠️ \(message)"
        case .error(let message):
            return "❌ \(message)"
        }
    }
}

/// Reports smart insights based on given variables.
public struct InsightsReporter: AilmentReporting {

    let title: String = "Insights"
    var insights: [IInsightSection]

    init() {
        var defaultInsights: [IInsightSection?] = [
            StorageInsights(),
            UpdateAvailableInsight()
        ]
        #if os(iOS) && !targetEnvironment(macCatalyst)
            defaultInsights.append(CellularAllowedInsight())
        #endif

        insights = defaultInsights.compactMap { $0 }
    }

    public func report() -> AilmentSector {
        let diagnostics: [String: String] = insights.compactMap { $0 }.reduce([:]) { partialResult, insight in
            var metadata = partialResult
            metadata[insight.sectionName] = insight.sectionResult.message
            return metadata
        }
        return AilmentSector(title: title,
                             diagnostics: diagnostics)
    }
}
