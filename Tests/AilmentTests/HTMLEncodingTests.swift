//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import XCTest
@testable import Ailment

final class HTMLEncodingTests: XCTestCase {

    /// It should correctly transform a String to HTML.
    func testAddingHTMLEncoding() {
        let value = "<CONTENT>"
        let expectedHTML = "&lt;CONTENT&gt;"
        XCTAssertEqual(value.addingHTMLEncoding(), expectedHTML)
    }

}
