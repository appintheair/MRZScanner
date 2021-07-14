//
//  LiveMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct LiveMRZScanner: MRZDefaultScannerService {
    public init() {}

    public func scanFrame(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        cleanOldAfter: Int? = 1,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<LiveDocuemntScanningResult, Error>) -> Void
    ) {
        scanner.scanLive(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            cleanOldAfter: cleanOldAfter,
            foundBoundingRectsHandler: foundBoundingRectsHandler,
            completionHandler: completionHandler
        )
    }
}
