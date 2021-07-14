//
//  MRZValidatorTests.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import XCTest
@testable import MRZScanner

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
            .init(result: "I<UTOD231458907<<<<<<<<<<<<<<<", index: 0),
            .init(result: "7408122F1204159UTO<<<<<<<<<<<6", index: 1),
            .init(result: "ERIKSSON<<ANNA<MARIA<<<<<<<<<<", index: 2),
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
            .init(result: "I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<", index: 0),
            .init(result: "D231458907UTO7408122F1204159<<<<<<<6", index: 1),
        ]

        let expectedValidatedResult = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResult, validatedResults)
    }

    func testEmptyValidation() {
        let validatedResults: ValidatedResults = []

        let expectedValidatedResult = validator.getValidatedResults(from: [])
        XCTAssertEqual(expectedValidatedResult, validatedResults)
    }

    func testTD3CleanValidation() {
        let valueToValidate = [
            ["P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<"],
            ["L898902C36UTO7408122F1204159ZE184226B<<<<<10"]
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<", index: 0),
            .init(result: "L898902C36UTO7408122F1204159ZE184226B<<<<<10", index: 1),
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
            .init(result: "I<UTOD231458907<<<<sdasdas<<<<<<<<<<", index: 0),
            .init(result: "ERIKSSON<<A22A<MARIA<<<<<<<<<<", index: 2),
        ]

        let expectedValidatedResults = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResults, validatedResults)
    }

    func testMRVADirtyValidation() {
        let valueToValidate = [
            [
                "V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<",
                "a",
                "sajkdhasjd2",
                "asdkjashdjhasdkjhdjksahdjkahsjdkh21321=391i3o1312890diwsad"
            ],
            [
                "7408122F1204159UTO<<<<<<<<<<1231231lk",
                "a1203981239",
                "L8988901C4XXX4009078F96121096ZE184226B<<<<<<",
                "1ncz z,mxcnmzcnms,sanmandakln amsd,nasldn"
            ]
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<", index: 0),
            .init(result: "L8988901C4XXX4009078F96121096ZE184226B<<<<<<", index: 1),
        ]

        let expectedValidatedResults = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResults, validatedResults)
    }

    func testMRVBDirtyValidation() {
        let valueToValidate = [
            [
                "asdass",
                "aasdjklasdlkasjdklasjdklasjd",
                "sajkdhasjd2",
                "asdkjashdjhasdkjhdjksahdjkahsjdkh21321=391i3o1312890diwsad"
            ],
            [
                "asdas<<<<<<a<<<<1231231lk",
                "V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<",
                "L8988901C4XXXsd4009078F96121096ZE1ss84226B<<<<<<",
                "1ncz z,mxcnmzcnms,sanmandakln aasdkalmsd,nasldn"
            ],
            [
                "asdass",
                "asdkljasdkjaslkdj",
                "asdkasdkljasdlkjaslkdjaslkdjaslk",
                "asdkjashdjhasdkjhdjksahdjkahsjdkh21321=391i3o1312890diwsad"
            ],
            [
                "7408122F120415aaaaaaaaUT<<<231231lk",
                "a1203981239",
                "L8988901C4XXX4009078F9612109<<<<<<<<",
                "1ncz z,mxscnmzcnms,sanmasssndakln amsd,nasldn"
            ],
            [
                "asdass",
                "a",
                "sajkdhasjd2",
                "asdkjashdjhasdkjhdjksahdjkahsjdkh21321=391i3o1312890diwsad"
            ],
        ]

        let validatedResults: ValidatedResults = [
            .init(result: "V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<", index: 1),
            .init(result: "L8988901C4XXX4009078F9612109<<<<<<<<", index: 3),
        ]

        let expectedValidatedResults = validator.getValidatedResults(from: valueToValidate)
        XCTAssertEqual(expectedValidatedResults, validatedResults)
    }
}

extension ValidatedResult: Equatable {
    public static func == (lhs: ValidatedResult, rhs: ValidatedResult) -> Bool {
        lhs.result == rhs.result && lhs.index == rhs.index
    }
}
