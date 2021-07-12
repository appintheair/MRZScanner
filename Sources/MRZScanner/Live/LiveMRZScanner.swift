//
//  LiveMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import Vision

public typealias LiveScanningResult = (result: ParserResult, accuracy: Int)

public struct LiveMRZScanner {
    private let liveResultTracker = LiveResultTracker()
    private let mrzScanner = MRZScanner()

    public init() {}

    public func scanFrame(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<ScanningResult<LiveScanningResult>, Error>) -> Void
    ) {
        mrzScanner.scan(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: .fast,
            foundBoundingRectsHandler: foundBoundingRectsHandler,
            completionHandler: {
                switch $0 {
                case .success(let scanningResult):
                    self.liveResultTracker.track(result: scanningResult.result)
                    guard let liveScanningResult = self.liveResultTracker.liveScanningResult else {
                        fatalError("liveScanningResult must be set")
                    }
                    completionHandler(
                        .success(
                            .init(
                                result: liveScanningResult,
                                boundingRects: scanningResult.boundingRects
                            )
                        )
                    )
                case .failure(let error):
                    if error is MRZScannerError {
                        return
                    } else {
                        completionHandler(.failure(error))
                    }
                }
            }
        )
    }

    /// Resets `LiveResultTracker` state
    public func resetLiveScanningSession() {
        liveResultTracker.reset()
    }
}
