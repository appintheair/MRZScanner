//
//  ScannerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import DocumentScanner

final class ScannerTests: XCTestCase {
    private var scanner: DocumentScanner.Scanner!

    override func setUp() {
        super.setUp()

        scanner = DocumentScanner.Scanner(
            textRecognizer: StubTextRecognizer(),
            validator: StubValidator(),
            parser: StubParser(),
            tracker: StubTracker()
        )
    }

    func testSingleEmpty() {
        scanSingle { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(_):
                return
            }
        }
    }

    func testLiveEmpty() {
        scanLive { rects in
            XCTFail()
        } completion: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(_):
                return
            }
        }

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
