//
//  MRZValidatorTests.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import XCTest
@testable import DocumentScanner

final class MRZValidatorTests: XCTestCase {
    private var validator: Validator!

    override func setUp() {
        super.setUp()

        validator = MRZValidator()
    }

    func testTD1CleanValidation() {
        let valueToValidate = [
            ["I<UTOD231458907<<<<<<<<<<<<<<<"],
            ["7408122F1204159UTO<<<<<<<<<<<6"],
            ["ERIKSSON<<ANNA<MARIA<<<<<<<<<<"]
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "I<UTOD231458907<<<<<<<<<<<<<<<", bouningRectIndex: 0),
            .init(result: "7408122F1204159UTO<<<<<<<<<<<6", bouningRectIndex: 1),
            .init(result: "ERIKSSON<<ANNA<MARIA<<<<<<<<<<", bouningRectIndex: 2),
        ]

        let expectedValidatedResult = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResult, validatedResults)
    }

    func testTD2CleanValidation() {
        let valueToValidate = [
            ["I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<"],
            ["D231458907UTO7408122F1204159<<<<<<<6"]
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<", bouningRectIndex: 0),
            .init(result: "D231458907UTO7408122F1204159<<<<<<<6", bouningRectIndex: 1),
        ]

        let expectedValidatedResult = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResult, validatedResults)
    }


    func testTD3CleanValidation() {
        let valueToValidate = [
            ["P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<"],
            ["L898902C36UTO7408122F1204159ZE184226B<<<<<10"]
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<", bouningRectIndex: 0),
            .init(result: "L898902C36UTO7408122F1204159ZE184226B<<<<<10", bouningRectIndex: 1),
        ]

        let expectedValidatedResult = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResult, validatedResults)
    }

    func testTD1DirtyValidation() {
        let valueToValidate = [
            [
                "I<UTOD231458907<<<<sdasdas<<<<<<<<<<",
                "I<UTOD231458907<<<asd<<<<<<<<<<<<",
                "I<UTO1231458807<<<<<2<<11<<<<<<<<",
                "1312312˚åß"
            ],
            [
                "7408122F1204159UTO<<<<<<<<<<<6",
                "7408122F12asd04159UTO<<<<<<<<<<<6",
                "7408122F1204159UTO<<<<s<<<<<a",
                "7408122F1204159UTO<<<<sda<<<<<<<a"
            ],
            [
                "ERIKSSON<<ANNA<<MARIA<<<<<<<<<<",
                "ERIKSSON<<A22A<MARIA<<<<<<<<<<",
                "EIKSSON<<ANNA<MARIA<<<<<<<<<<",
                "ERIKSSON<<ANNA<MARIA<<<<<<<<<<"
            ]
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "I<UTOD231458907<<<<sdasdas<<<<<<<<<<", bouningRectIndex: 0),
            .init(result: "ERIKSSON<<A22A<MARIA<<<<<<<<<<", bouningRectIndex: 2),
        ]

        let expectedValidatedResults = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResults, validatedResults)
    }
}

extension ValidatedResult: Equatable {
    public static func == (lhs: ValidatedResult, rhs: ValidatedResult) -> Bool {
        lhs.result == rhs.result && lhs.bouningRectIndex == rhs.bouningRectIndex
    }
}
