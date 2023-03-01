//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import XCTest
@testable import Ailment

final class UserDefaultsReporterTests: XCTestCase {

    /// It should show the user defaults in the report.
    func testReportUserDefaults() {
        let expectedValue = UUID().uuidString
        UserDefaults.standard.set(expectedValue, forKey: "test_key")
        let diagnostics = UserDefaultsReporter().report().diagnostics as! [String: Any]
        XCTAssertEqual(diagnostics["test_key"] as? String, expectedValue)
    }

}
