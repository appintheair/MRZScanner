//
//  TrackerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import DocumentScanner

class TrackerTests<T: Tracker>: XCTestCase {
    var tracker: T!

    private let firstExampleMRZResult = ParsedResult(
        format: .td3,
        documentType: .passport,
        countryCode: "",
        surnames: "",
        givenNames: "",
        documentNumber: nil,
        nationalityCountryCode: "",
        birthdate: nil,
        sex: .male,
        expiryDate: nil,
        optionalData: nil,
        optionalData2: nil
    )

    private let secondExampleMRZResult = ParsedResult(
        format: .td2,
        documentType: .id,
        countryCode: "",
        surnames: "",
        givenNames: "",
        documentNumber: nil,
        nationalityCountryCode: "",
        birthdate: nil,
        sex: .male,
        expiryDate: nil,
        optionalData: nil,
        optionalData2: nil
    )

    func testOneExample() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 1)
        ])
    }

    func testTwoExamples() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 3),
            Array(repeating: secondExampleMRZResult, count: 2),
        ])
    }

    func testTwoExamplesWithLongDetectionOne() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 60),
            Array(repeating: secondExampleMRZResult, count: 31),
        ])
    }

    func testTwoExamplesWithLongDetectionTwo() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 60),
            Array(repeating: secondExampleMRZResult, count: 25),
        ])
    }

    func testTwoExamplesWithLongDetectionThree() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 25),
            Array(repeating: secondExampleMRZResult, count: 30),
        ])
    }

    func testReset() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 3),
            Array(repeating: secondExampleMRZResult, count: 6),
        ])

        tracker.reset()

        testSequentialAddition(arrayOfExamples: [
            Array(repeating: firstExampleMRZResult, count: 9),
            Array(repeating: secondExampleMRZResult, count: 1),
        ])
    }

    private func testSequentialAddition(arrayOfExamples: [[ParsedResult]]) {
        XCTAssertNil(tracker.bestResult)

        for examples in arrayOfExamples {
            for example in examples {
                tracker.track(result: example, cleanOldAfter: 1)
            }
        }

        var arrayOfExamples = arrayOfExamples
        if let lastFrequentExamplesIndex = arrayOfExamples.lastIndex(where: { $0.count > 1 * 30 }) {
            arrayOfExamples = Array(arrayOfExamples.suffix(from: lastFrequentExamplesIndex))
        }

        let sortedExamples = arrayOfExamples.sorted { $0.count > $1.count }
        let mostProbableExamples = sortedExamples.first
        XCTAssertNotNil(mostProbableExamples)

        let mostProbableExample = mostProbableExamples!.first
        checkResult(mostProbableExample, accuracy: mostProbableExamples!.count)
    }

    private func checkResult(_ result: ParsedResult?, accuracy: Int) {
        XCTAssertEqual(tracker.bestResult?.result, result)
        XCTAssertEqual(tracker.bestResult?.accuracy, accuracy)
    }
}
