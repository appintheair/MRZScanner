//
//  FrequencyTrackerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import MRZScanner

final class FrequencyTrackerTests: XCTestCase {
    private var tracker: Tracker!
    private let frequency = 8

    override func setUp() {
        super.setUp()

        tracker = FrequencyTracker(frequency: frequency)
    }

    func testOneResultFrequencyTimes() {
        for _ in 0 ..< frequency - 1 {
            _ = tracker.isResultStable(StubModels.firstParsedResult)
        }

        XCTAssertTrue(tracker.isResultStable(StubModels.firstParsedResult))
    }

    func testOneResultOneTime() {
        XCTAssertFalse(tracker.isResultStable(StubModels.firstParsedResult))
    }

    func testTwoResultsFrequencyTimes() {
        _ = tracker.isResultStable(StubModels.firstParsedResult)
        XCTAssertFalse(tracker.isResultStable(StubModels.firstParsedResult))
    }

    func testTwoResultFrequencyTimes() {
        for _ in 0 ..< 2  {
            _ = tracker.isResultStable(StubModels.firstParsedResult)
        }

        for _ in 0 ..< 2 {
            _ = tracker.isResultStable(StubModels.secondParsedResult)
        }

        for _ in 0 ..< 3  {
            _ = tracker.isResultStable(StubModels.firstParsedResult)
        }

        for _ in 0 ..< 1  {
            _ = tracker.isResultStable(StubModels.secondParsedResult)
        }

        XCTAssertFalse(tracker.isResultStable(StubModels.firstParsedResult))
    }
}
