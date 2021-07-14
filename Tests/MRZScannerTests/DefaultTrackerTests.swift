//
//  DefaultTrackerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import MRZScanner

final class DefaultTrackerTests: XCTestCase {
    private var tracker: Tracker!

    override func setUp() {
        super.setUp()

        tracker = DefaultTracker()
    }

    func testOneExample() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 1)
        ])
    }

    func testTwoExamples() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 3),
            Array(repeating: StubModels.secondParsedResultStub, count: 2),
        ])
    }

    func testTwoExamplesWithLongDetectionOne() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 60),
            Array(repeating: StubModels.secondParsedResultStub, count: 31),
        ])
    }

    func testTwoExamplesWithLongDetectionTwo() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 60),
            Array(repeating: StubModels.secondParsedResultStub, count: 25),
        ])
    }

    func testTwoExamplesWithLongDetectionThree() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 25),
            Array(repeating: StubModels.secondParsedResultStub, count: 30),
        ])
    }

    func testReset() {
        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 3),
            Array(repeating: StubModels.secondParsedResultStub, count: 6),
        ])

        tracker.reset()

        testSequentialAddition(arrayOfExamples: [
            Array(repeating: StubModels.firstParsedResultStub, count: 9),
            Array(repeating: StubModels.secondParsedResultStub, count: 1),
        ])
    }

    private func testSequentialAddition(arrayOfExamples: [[ParsedResult]]) {
        /// One second
        let cleanOldAfter = 1

        var lastTrackedResult: TrackedResult?
        for examples in arrayOfExamples {
            for example in examples {
                lastTrackedResult = tracker.track(result: example, cleanOldAfter: cleanOldAfter)
            }
        }

        var arrayOfExamples = arrayOfExamples
        if let lastFrequentExamplesIndex = arrayOfExamples.lastIndex(where: { $0.count > cleanOldAfter * 30 }) {
            arrayOfExamples = Array(arrayOfExamples.suffix(from: lastFrequentExamplesIndex))
        }

        let sortedExamples = arrayOfExamples.sorted { $0.count > $1.count }
        let mostProbableExamples = sortedExamples.first
        XCTAssertNotNil(mostProbableExamples)

        let mostProbableExample = mostProbableExamples?.first

        XCTAssertEqual(mostProbableExample, lastTrackedResult?.result)
        XCTAssertEqual(mostProbableExamples?.count, lastTrackedResult?.accuracy)
    }
}
