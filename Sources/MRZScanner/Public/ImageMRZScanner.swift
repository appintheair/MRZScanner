//
//  ImageMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct ImageMRZScanner: MRZDefaultScannerService {
    public init() {}

    public func scan(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        recognitionLevel: RecognitionLevel = .accurate,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        scanner.scanSingle(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: recognitionLevel,
            completionHandler: completionHandler
        )
    }
}

