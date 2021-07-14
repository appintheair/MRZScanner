//
//  LiveMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct LiveMRZScanner {
    private var scanner: Scanner {
        Scanner(textRecognizer: textRecognizer, validator: validator, parser: parser)
    }

    private let textRecognizer: TextRecognizer
    private let validator: Validator
    private let parser: Parser
    private let tracker: Tracker

    public init() {
        textRecognizer = VisionTextRecognizer()
        validator = MRZValidator()
        parser = MRZLineParser()
        tracker = DefaultTracker()
    }

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser, tracker: Tracker) {
        self.textRecognizer = textRecognizer
        self.validator = validator
        self.parser = parser
        self.tracker = tracker
    }

    public func scanFrame(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        cleanOldAfter: Int? = 1,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<LiveDocuemntScanningResult, Error>) -> Void
    ) {
        scanner.scan(
            scanningType: .live,
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: .fast,
            foundBoundingRectsHandler: foundBoundingRectsHandler,
            completionHandler: { result in
                switch result {
                case .success(let scanningResult):
                    tracker.track(result: scanningResult.result, cleanOldAfter: cleanOldAfter)
                    guard let bestResult = tracker.bestResult else { fatalError("bestResult should be here") }
                    completionHandler(
                        .success(.init(
                            result: .init(
                                result: bestResult.result,
                                boundingRects: scanningResult.boundingRects
                            ),
                            accuracy: bestResult.accuracy
                        ))
                    )
                case .failure(let error):
                    completionHandler(.failure(error))
            }
            }
        )
    }
}
