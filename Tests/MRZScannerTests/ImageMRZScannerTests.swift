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
        .init(textRecognizer: textRecognizer, validator: validator, parser: parser)
    }

    private var textRecognizer: StubTextRecognizer!
    private var validator: StubValidator!
    private var parser: StubParser!

    override func setUp() {
        super.setUp()

        textRecognizer = StubTextRecognizer()
        validator = StubValidator()
        parser = StubParser()
    }

    func testSuccess() {
        let expectation = XCTestExpectation()
        textRecognizer.recognizeResult = .success([CGRect(): ["asdasd"]])
        validator.validatedResults = [.init(result: "asdasd", index: 0)]
        parser.parsedResult = StubModels.firstParsedResultStub
        imageMRZScanner.scan(pixelBuffer: StubModels.sampleBufferStub, orientation: .up) { result in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
