//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import XCTest
@testable import Ailment

final class InsightsReporterTests: XCTestCase {

    func testInsightsChapter() throws {
        let reporter = InsightsReporter()
        let chapter = reporter.report()
        XCTAssertEqual(chapter.title, "Insights")
        let insightsDictionary = try XCTUnwrap(chapter.diagnostics as? [String: String])
        XCTAssertFalse(insightsDictionary.isEmpty)
    }

    func testRemovingDuplicateInsights() throws {
        var reporter = InsightsReporter()
        let insight = Insights(sectionName: UUID().uuidString, sectionResult: .success(message: UUID().uuidString))

        /// Remove default insights to make this test independent.
        reporter.insights.removeAll()

        reporter.insights.append(contentsOf: [insight, insight, insight])

        let chapter = reporter.report()
        XCTAssertEqual(chapter.title, "Insights")
        let insightsDictionary = try XCTUnwrap(chapter.diagnostics as? [String: String])
        XCTAssertEqual(insightsDictionary.count, 1, "It should only have one of the custom insights")
    }
}
