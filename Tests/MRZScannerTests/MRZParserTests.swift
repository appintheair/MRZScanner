//
//  MRZParserTests.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import XCTest
@testable import MRZScanner

final class MRZParserTests: XCTestCase {
    private var parser: Parser!

    override func setUp() {
        super.setUp()

        parser = MRZLineParser()
    }

    func testSuccess() {
        let parsedResult = parser.parse(
            lines: [
                "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<",
                "L898902C36UTO7408122F1204159ZE184226B<<<<<10"
            ]
        )

        XCTAssertEqual(parsedResult, StubModels.firstParsedResult)
    }

    func testError() {
        let parsedResult = parser.parse(
            lines: []
        )

        XCTAssertNil(parsedResult)
    }
}
