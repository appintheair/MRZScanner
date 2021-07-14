//
//  LiveMRZScannerTests.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import XCTest
@testable import MRZScanner

final class LiveMRZScannerTests: XCTestCase {
    private var liveMRZScanner: LiveMRZScanner { .init(tracker: tracker) }
    private var tracker: StubTracker!

    override func setUp() {
        super.setUp()

        tracker = StubTracker()
    }

    func testSuccess() {
        let trackedResult = (StubModels.firstParsedResultStub, 3)
        tracker.trackedResult = trackedResult
        liveMRZScanner.scanFrame(pixelBuffer: StubModels.sampleBufferStub, orientation: .up) { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(scanningResult.accuracy, trackedResult.1)
                XCTAssertEqual(scanningResult.result.result, trackedResult.0)
            case .failure:
                XCTFail()
            }
        }
    }
}
