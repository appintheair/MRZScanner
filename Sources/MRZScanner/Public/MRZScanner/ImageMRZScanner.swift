//
//  ImageMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct ImageMRZScanner: ScannerService {
    let scanner: DefaultScanner

    public init() {
        scanner = DefaultScanner(
            textRecognizer: VisionTextRecognizer(),
            validator: MRZValidator(),
            parser: MRZLineParser()
        )
    }

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser) {
        scanner = DefaultScanner(
            textRecognizer: textRecognizer,
            validator: validator,
            parser: parser
        )
    }

    public func scan(
        scanningImage: ScanningImage,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        recognitionLevel: RecognitionLevel = .accurate,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        scanner.scan(
            scanningType: .single,
            scanningImage: scanningImage,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: recognitionLevel,
            foundBoundingRectsHandler: foundBoundingRectsHandler,
            completionHandler: completionHandler
        )
    }
}

