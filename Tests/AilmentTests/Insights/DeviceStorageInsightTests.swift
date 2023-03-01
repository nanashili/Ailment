//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

import XCTest
@testable import Ailment

final class DeviceStorageInsightTests: XCTestCase {

    func testLowOnStorage() {
        let insight = StorageInsights(freeDiskSpace: 800 * 1000 * 1000, totalDiskSpace: "100GB")
        XCTAssertEqual(insight.sectionResult, .warn(message: "The user is low on storage (800 MB of 100GB left)"))
    }

    func testEnoughStorage() {
        let insight = StorageInsights(freeDiskSpace: 8000 * 1000 * 1000, totalDiskSpace: "100GB")
        XCTAssertEqual(insight.sectionResult, .success(message: "The user has enough storage (8 GB of 100GB left)"))
    }

}
