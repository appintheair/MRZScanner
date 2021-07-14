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
    private let frequency = 4

    override func setUp() {
        super.setUp()

        tracker = FrequencyTracker(frequency: frequency)
    }

    func testOneResultFrequencyTimes() {
        for _ in 0 ..< frequency - 1 {
            _ = tracker.isResultStable(StubModels.firstParsedResultStub)
        }

        XCTAssertTrue(tracker.isResultStable(StubModels.firstParsedResultStub))
    }

    func testOneResultOneTime() {
        XCTAssertFalse(tracker.isResultStable(StubModels.firstParsedResultStub))
    }

    func testTwoResultsFrequencyTimes() {
        _ = tracker.isResultStable(StubModels.firstParsedResultStub)
        XCTAssertFalse(tracker.isResultStable(StubModels.firstParsedResultStub))
    }

    func testTwoResultFrequencyTimes() {
        for _ in 0 ..< 2  {
            _ = tracker.isResultStable(StubModels.firstParsedResultStub)
        }

        for _ in 0 ..< 4 {
            _ = tracker.isResultStable(StubModels.secondParsedResultStub)
        }

        for _ in 0 ..< 5  {
            _ = tracker.isResultStable(StubModels.firstParsedResultStub)
        }

        for _ in 0 ..< 1  {
            _ = tracker.isResultStable(StubModels.firstParsedResultStub)
        }


        XCTAssertTrue(tracker.isResultStable(StubModels.firstParsedResultStub))
    }
}
