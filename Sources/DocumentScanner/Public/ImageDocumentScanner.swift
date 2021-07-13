//
//  ImageMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct ImageDocumentScanner {
    private let scanner: Scanner
    private let validator: Validator
    private let parser: Parser
    private let manager: Manager

    // TODO: Add `Configuraton` struct
    public init() {
        scanner = VisionScanner()
        validator = MRZValidator()
        parser = MRZLineParser()
        manager = DefaultManager()
    }

    init(scanner: Scanner, validator: Validator, parser: Parser, manager: Manager) {
        self.scanner = scanner
        self.validator = validator
        self.parser = parser
        self.manager = manager
    }

    func scan(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        recognitionLevel: RecognitionLevel = .accurate,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        scanner.scan(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: recognitionLevel
        ) {
            switch $0 {
            case .success(let results):
                let validLines = validator.validLines(from: results.map { $0.value })
                guard let parserResult = parser.parse(lines: validLines.map { $0.key }) else {
                    completionHandler(.failure(ImageScanningError.codeNotFound))
                    return
                }

                let managerResult = manager.merge(
                    allBoundingRects: results.map { $0.key },
                    validRectIndexes: validLines.map { $0.value }
                )

                completionHandler(.success(.init(result: parserResult, boundingRects: managerResult)))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    enum ImageScanningError: Error {
        case codeNotFound
    }
}

