//
//  LiveMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct LiveMRZScanner: MRZDefaultScannerService {
    private let tracker: Tracker

    public init() {
        self.tracker = DefaultTracker()
    }

    init(tracker: Tracker) {
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
