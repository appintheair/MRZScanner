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

    /// - Parameter frequency: Number of times the result was encountered
    public init(frequency: Int = 2) {
        textRecognizer = VisionTextRecognizer()
        validator = MRZValidator()
        parser = MRZLineParser()
        tracker = FrequencyTracker(frequency: frequency)
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
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
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
                    guard tracker.isResultStable(scanningResult.result) else { return }

                    completionHandler(
                        .success(.init(
                            result: scanningResult.result,
                            boundingRects: scanningResult.boundingRects
                        ))
                    )
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        )
    }

    public func resetFrequency() {
        tracker.reset()
    }
}
