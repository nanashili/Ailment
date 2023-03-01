//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import XCTest
@testable import Ailment

final class DiagnosticsReporterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        try! AilmentLogger.setup()
    }

    override func tearDown() {
        try! AilmentLogger.standard.deleteLogs()
        super.tearDown()
    }

    /// It should correctly generate HTML from the reporters.
    func testHTMLGeneration() {
        let ailmentSector = AilmentSector(title: UUID().uuidString, diagnostics: UUID().uuidString)
        var reporter = MockedReporter()
        reporter.ailmentSector = ailmentSector
        let reporters = [reporter]
        let report = AilmentReporter.create(using: reporters)
        let html = String(data: report.data, encoding: .utf8)!

        XCTAssertTrue(html.contains("<h3>\(ailmentSector.title)</h3>"))
        XCTAssertTrue(html.contains(ailmentSector.diagnostics as! String))
    }

    /// It should create a chapter for each reporter.
    func testReportingChapters() {
        let report = AilmentReporter.create()
        let html = String(data: report.data, encoding: .utf8)!
        let expectedChaptersCount = AilmentReporter.DefaultReporter.allCases.count
        let chaptersCount = html.components(separatedBy: "<div class=\"chapter\"").count - 1
        XCTAssertEqual(expectedChaptersCount, chaptersCount)
    }

    /// It should filter using passed filters.
    func testFilters() {
        let keyToFilter = UUID().uuidString
        let mockedReport = MockedReport(diagnostics: [keyToFilter: UUID().uuidString])
        let report = AilmentReporter.create(using: [mockedReport], filters: [MockedFilter.self])
        let html = String(data: report.data, encoding: .utf8)!
        XCTAssertFalse(html.contains(keyToFilter))
        XCTAssertTrue(html.contains("FILTERED"))
    }

    func testWithoutProvidingSmartInsightsProvider() {
        let mockedReport = MockedReport(diagnostics: ["key": UUID().uuidString])
        let report = AilmentReporter.create(using: [mockedReport, InsightsReporter()],
                                            filters: [MockedFilter.self],
                                            smartInsightsProvider: nil)
        let html = String(data: report.data, encoding: .utf8)!
        XCTAssertTrue(html.contains("Insights"), "Default insights should still be added")
    }

    func testWithSmartInsightsProviderReturningNoExtraInsights() {
        let mockedReport = MockedReport(diagnostics: ["key": UUID().uuidString])
        let report = AilmentReporter.create(using: [mockedReport, InsightsReporter()],
                                            filters: [MockedFilter.self],
                                            smartInsightsProvider: MockedInsightsProvider(insightToReturn: nil))
        let html = String(data: report.data, encoding: .utf8)!
        XCTAssertTrue(html.contains("Insights"), "Default insights should still be added")
    }

    func testWithSmartInsightsProviderReturningExtraInsights() {
        let mockedReport = MockedReport(diagnostics: ["key": UUID().uuidString])
        let insightToReturn = Insights(sectionName: UUID().uuidString,
                                       sectionResult: .success(message: UUID().uuidString))
        let report = AilmentReporter.create(using: [mockedReport, InsightsReporter()],
                                            filters: [MockedFilter.self],
                                            smartInsightsProvider: MockedInsightsProvider(insightToReturn: insightToReturn))
        let html = String(data: report.data, encoding: .utf8)!
        XCTAssertTrue(html.contains(insightToReturn.sectionName))
        XCTAssertTrue(html.contains(insightToReturn.sectionResult.message))
    }

    /// It should correctly generate the header.
    func testHeaderGeneration() {
        let report = AilmentReporter.create(using: [])
        let html = String(data: report.data, encoding: .utf8)!

        XCTAssertTrue(html.contains("<head>"))
        XCTAssertTrue(html.contains("<title>\(AilmentReporter.reportTitle)</title>"))
        XCTAssertTrue(html.contains(AilmentReporter.style()))
        XCTAssertTrue(html.contains("</head>"))
    }
}

struct MockedReport: AilmentReporting {
    var diagnostics: Ailment = [:]
    func report() -> AilmentSector {
        return AilmentSector(title: UUID().uuidString, diagnostics: diagnostics)
    }
}

struct MockedFilter: AilmentFilter {
    static func filter(_ diagnostics: Ailment) -> Ailment {
        return "FILTERED"
    }
}

struct MockedInsightsProvider: SmartInsightsProviding {
    let insightToReturn: IInsightSection?

    func smartInsights(for chapter: AilmentSector) -> [IInsightSection] {
        guard let insightToReturn = insightToReturn else {
            return []
        }

        return [insightToReturn]
    }
}
