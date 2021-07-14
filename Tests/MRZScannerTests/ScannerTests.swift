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
        .init(textRecognizer: textRecognizer, validator: validator, parser: parser, tracker: tracker)
    }
    private var textRecognizer = StubTextRecognizer()
    private var validator = StubValidator()
    private var parser = StubParser()
    private var tracker = StubTracker()

    override func setUp() {
        super.setUp()
        textRecognizer = StubTextRecognizer()
        validator = StubValidator()
        parser = StubParser()
        tracker = StubTracker()
    }

    // MARK: Single

    func testaSingleRecognizeError() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .failure(TestError.testError)
        scanSingle { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is TestError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testaSingleComplete() {
        let expectation = XCTestExpectation()
        validator.validatedResults = [.init(result: "asdasd", index: 0)]
        textRecognizer.recognizeResult = .success([CGRect(): ["asdasd"]])
        parser.parsedResult = StubModels.firstExampleParsedResult
        scanSingle { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(StubModels.firstExampleParsedResult, scanningResult.result)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: Live

    func testaLiveRecognizeError() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .failure(TestError.testError)
        scanLive { rects in
            XCTFail()
        } completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is TestError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testLiveComplete() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success([CGRect(): ["asdasd"]])
        validator.validatedResults = [.init(result: "asdasd", index: 0)]
        parser.parsedResult = StubModels.firstExampleParsedResult
        tracker.trackedResult = (StubModels.firstExampleParsedResult, 1)
        scanLive { _ in
        } completion: { result in
            switch result {
            case .success(let scanningResult):
                XCTAssertEqual(StubModels.firstExampleParsedResult, scanningResult.result.result)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    private func scanSingle(completion: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void) {
        scanner.scanSingle(
            pixelBuffer: createExampleSampleBuffer(),
            orientation: .up,
            regionOfInterest: nil,
            minimumTextHeight: nil,
            completionHandler: completion
        )
    }

    private func scanLive(
        rectsHandler: (([CGRect]) -> Void)?,
        completion: @escaping (Result<LiveDocuemntScanningResult, Error>) -> Void
    ) {
        scanner.scanLive(
            pixelBuffer: createExampleSampleBuffer(),
            orientation: .up,
            regionOfInterest: nil,
            minimumTextHeight: nil,
            cleanOldAfter: nil,
            foundBoundingRectsHandler: rectsHandler,
            completionHandler: completion
        )
    }

    private func createExampleSampleBuffer() -> CVPixelBuffer {
        var pixelBuffer : CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        return pixelBuffer!
    }
}

enum TestError: Error {
    case testError
}

