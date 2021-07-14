//
//  LiveMRZScannerTests.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import XCTest
@testable import MRZScanner

final class LiveMRZScannerTests: XCTestCase {
    private var liveMRZScanner: LiveMRZScanner {
        .init(textRecognizer: textRecognizer, validator: validator, parser: parser, tracker: tracker)
    }
    
    private var textRecognizer: StubTextRecognizer!
    private var validator: StubValidator!
    private var parser: StubParser!
    private var tracker: StubTracker!

    override func setUp() {
        super.setUp()

        textRecognizer = StubTextRecognizer()
        validator = StubValidator()
        parser = StubParser()
        tracker = StubTracker()
    }

    func testSuccess() {
        textRecognizer.recognizeResult = .success([CGRect(): ["asdasd"]])
        validator.validatedResults = [.init(result: "asdasd", index: 0)]
        parser.parsedResult = StubModels.firstParsedResultStub
        let trackedResult = (StubModels.firstParsedResultStub, 3)
        let expectation = XCTestExpectation()
        liveMRZScanner.scanFrame(pixelBuffer: StubModels.sampleBufferStub, orientation: .up) { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(scanningResult.result, trackedResult.0)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testTrackerFail() {
        textRecognizer.recognizeResult = .success([CGRect(): ["asdasd"]])
        validator.validatedResults = [.init(result: "asdasd", index: 0)]
        parser.parsedResult = StubModels.firstParsedResultStub
        tracker.isResultStable = false
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        liveMRZScanner.scanFrame(pixelBuffer: StubModels.sampleBufferStub, orientation: .up) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
