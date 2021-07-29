//
//  LiveMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public final class LiveMRZScanner: ScannerService, LiveScanner {
    let scanner: DefaultScanner
    let tracker: Tracker

    /// - Parameter frequency: Number of times the result was encountered
    public init(frequency: Int = 2) {
        scanner = DefaultScanner(
            textRecognizer: VisionTextRecognizer(),
            validator: MRZValidator(),
            parser: MRZLineParser()
        )

        tracker = FrequencyTracker(frequency: frequency)
    }

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser, tracker: Tracker) {
        scanner = DefaultScanner(
            textRecognizer: textRecognizer,
            validator: validator,
            parser: parser
        )

        self.tracker = tracker
    }

    public func scanFrame(
        scanningImage: ScanningImage,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        scanner.scan(
            scanningType: .live,
            scanningImage: scanningImage,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: .fast,
            foundBoundingRectsHandler: foundBoundingRectsHandler,
            completionHandler: { result in
                switch result {
                case .success(let scanningResult):
                    guard self.tracker.isResultStable(scanningResult.result) else { return }

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
}
