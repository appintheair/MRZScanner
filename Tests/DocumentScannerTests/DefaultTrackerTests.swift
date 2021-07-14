//
//  DefaultTrackerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import DocumentScanner

final class DefaultTrackerTests: XCTestCase {
    private var tracker: Tracker!

    override func setUp() {
        super.setUp()

        tracker = DefaultTracker()
    }

    func testOneExample() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 1)
        ])
    }

    func testTwoExamples() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 3),
            Array(repeating: StubModels.secondExampleParsedResult, count: 2),
        ])
    }

    func testTwoExamplesWithLongDetectionOne() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 60),
            Array(repeating: StubModels.secondExampleParsedResult, count: 31),
        ])
    }

    func testTwoExamplesWithLongDetectionTwo() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 60),
            Array(repeating: StubModels.secondExampleParsedResult, count: 25),
        ])
    }

    func testTwoExamplesWithLongDetectionThree() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 25),
            Array(repeating: StubModels.secondExampleParsedResult, count: 30),
        ])
    }

    func testReset() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 3),
            Array(repeating: StubModels.secondExampleParsedResult, count: 6),
        ])

        tracker.reset()

        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstExampleParsedResult, count: 9),
            Array(repeating: StubModels.secondExampleParsedResult, count: 1),
        ])
    }

    private func testSequentialAddition(arrayOfExamples: [[ParsedResult]]) {
        XCTAssertNil(tracker.bestResult)

        /// One second
        let cleanOldAfter = 1

        for examples in arrayOfExamples {
            for example in examples {
                tracker.track(result: example, cleanOldAfter: cleanOldAfter)
            }
        }

        var arrayOfExamples = arrayOfExamples
        if let lastFrequentExamplesIndex = arrayOfExamples.lastIndex(where: { $0.count > cleanOldAfter * 30 }) {
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
