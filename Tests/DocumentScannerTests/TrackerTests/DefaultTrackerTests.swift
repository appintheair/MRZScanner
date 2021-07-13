//
//  TrackerTests.swift
//
//
//  Created by Roman Mazeev on 12.07.2021.
//

@testable import DocumentScanner

final class DefaultTrackerTests: TrackerTests<DefaultTracker> {
    override func setUp() {
        super.setUp()

        tracker = DefaultTracker()
    }
}
