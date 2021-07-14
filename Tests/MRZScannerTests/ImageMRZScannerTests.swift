//
//  ImageMRZScannerTests.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import XCTest
@testable import MRZScanner

final class ImageMRZScannerTests: XCTestCase {
    private var imageMRZScanner: ImageMRZScanner {
        .init(textRecognizer: textRecognizer, validator: StubValidator(), parser: parser)
    }

    private var textRecognizer: StubTextRecognizer!
    private var parser: StubParser!

    override func setUp() {
        super.setUp()

        textRecognizer = StubTextRecognizer()
        parser = StubParser()
    }

    func testSuccess() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success(StubModels.textRecognizerResults)
        parser.parsedResult = StubModels.firstParsedResult
        imageMRZScanner.scan(pixelBuffer: StubModels.sampleBufferStub, orientation: .up) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
