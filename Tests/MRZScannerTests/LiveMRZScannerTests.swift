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
        .init(textRecognizer: textRecognizer, validator: StubValidator(), parser: parser, tracker: tracker)
    }

    private var textRecognizer: StubTextRecognizer!
    private var parser: StubParser!
    private var tracker: StubTracker!

    override func setUp() {
        super.setUp()

        textRecognizer = StubTextRecognizer()
        parser = StubParser()
        tracker = StubTracker()
    }

    func testSuccess() {
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)
        parser.parsedResult = StubModels.firstParsedResult
        tracker.isResultStable = true
        let expectation = XCTestExpectation()
        liveMRZScanner.scanFrame(scanningImage: .pixelBuffer(StubModels.sampleBufferStub), orientation: .up) { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(scanningResult.result, StubModels.firstParsedResult)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testFailure() {
        textRecognizer.recognizeResult = .failure(StubError.stub)
        let expectation = XCTestExpectation()
        liveMRZScanner.scanFrame(scanningImage: .pixelBuffer(StubModels.sampleBufferStub), orientation: .up) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is StubError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testTrackerFailure() {
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)
        parser.parsedResult = StubModels.firstParsedResult
        tracker.isResultStable = false
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        liveMRZScanner.scanFrame(scanningImage: .pixelBuffer(StubModels.sampleBufferStub), orientation: .up) { result in
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
