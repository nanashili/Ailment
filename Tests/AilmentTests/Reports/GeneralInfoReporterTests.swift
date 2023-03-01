//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import XCTest
@testable import Ailment

final class GeneralInfoReporterTests: XCTestCase {

    /// It should include the title in the report.
    func testTitle() {
        XCTAssertEqual(GeneralReporter().report().title, "Information")
    }

    func testDescription() {
        let reporter = GeneralReporter()
        let diagnostics = reporter.report().diagnostics as! String
        XCTAssertEqual(diagnostics, reporter.description)
    }

}
