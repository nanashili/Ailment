//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import XCTest
@testable import Ailment

final class AppSystemMetadataReporterTests: XCTestCase {

    /// It should correctly add the metadata.
    func testMetadata() {
        let metadata = AppMetadataReporter().report().diagnostics as! [String: String]

        XCTAssertEqual(metadata[AppMetadataReporter.MetadataKey.appName.rawValue], Bundle.appName)
        XCTAssertEqual(metadata[AppMetadataReporter.MetadataKey.appVersion.rawValue], "\(Bundle.appVersion) (\(Bundle.appBuildNumber))")
        XCTAssertEqual(metadata[AppMetadataReporter.MetadataKey.appLanguage.rawValue], "en-US")
    }
}
