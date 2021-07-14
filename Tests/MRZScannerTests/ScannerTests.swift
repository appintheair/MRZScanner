//
//  ScannerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import MRZScanner

final class ScannerTests: XCTestCase {
    private var scanner: MRZScanner.Scanner {
        .init(textRecognizer: textRecognizer, validator: validator, parser: parser)
    }
    private var textRecognizer: StubTextRecognizer!
    private var parser: StubParser!
    private var tracker: StubTracker!
    private var validator: StubValidator!

    override func setUp() {
        super.setUp()
        textRecognizer = StubTextRecognizer()
        parser = StubParser()
        tracker = StubTracker()
        validator = StubValidator()
    }

    // MARK: Single

    func testaSingleComplete() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)
        validator.validatedResults = StubModels.validatedResults
        parser.parsedResult = StubModels.firstParsedResult
        scan(scanningType: .single) { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(StubModels.firstParsedResult, scanningResult.result)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testaSingleRecognizeError() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .failure(StubError.stub)
        scan(scanningType: .single) { result in
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

    func testSingleParserError() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        scan(scanningType: .single) { rects in
            XCTFail()
        } completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: Live

    func testLiveComplete() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)
        parser.parsedResult = StubModels.firstParsedResult
        scan(scanningType: .live) { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(StubModels.firstParsedResult, scanningResult.result)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testLiveRecognizeError() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .failure(StubError.stub)
        scan(scanningType: .live) { rects in
            XCTFail()
        } completion: { result in
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

    func testLiveParserError() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        scan(scanningType: .live) { rects in
            XCTFail()
        } completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTFail()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    private func scan(
        scanningType: MRZScanner.Scanner.ScanningType,
        rectsHandler: (([CGRect]) -> Void)? = nil,
        completion: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>
    ) -> Void) {
        scanner.scan(
            scanningType: scanningType,
            pixelBuffer: StubModels.sampleBufferStub,
            orientation: .up,
            regionOfInterest: nil,
            minimumTextHeight: nil,
            recognitionLevel: scanningType == .live ? .fast : .accurate,
            completionHandler: completion
        )
    }
}
