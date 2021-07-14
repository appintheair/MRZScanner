//
//  ImageMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct ImageMRZScanner {
    private var scanner: Scanner {
        Scanner(textRecognizer: textRecognizer, validator: validator, parser: parser)
    }

    private let textRecognizer: TextRecognizer
    private let validator: Validator
    private let parser: Parser

    public init() {
        textRecognizer = VisionTextRecognizer()
        validator = MRZValidator()
        parser = MRZLineParser()
    }

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser) {
        self.textRecognizer = textRecognizer
        self.validator = validator
        self.parser = parser
    }

    public func scan(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        recognitionLevel: RecognitionLevel = .accurate,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        scanner.scan(
            scanningType: .single,
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: recognitionLevel,
            completionHandler: completionHandler
        )
    }
}

