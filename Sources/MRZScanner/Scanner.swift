//
//  Scanner.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import CoreImage

struct Scanner {
    enum ScanningError: Error {
        case codeNotFound
    }

    enum ScanningType {
        case live
        case single
    }

    private let textRecognizer: TextRecognizer
    private let validator: Validator
    private var parser: Parser

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser) {
        self.textRecognizer = textRecognizer
        self.validator = validator
        self.parser = parser
    }

    func scan(
        scanningType: ScanningType,
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        textRecognizer.recognize(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: .fast
        ) {
            switch $0 {
            case .success(let results):
                if scanningType == .live {
                    DispatchQueue.main.async {
                        foundBoundingRectsHandler?(results.map { $0.key })
                    }
                }

                let validatedResult = validator.getValidatedResults(from: results.map { $0.value })
                guard let parsedResult = parser.parse(lines: validatedResult.map { $0.result }) else {
                    if scanningType == .single {
                        DispatchQueue.main.async {
                            completionHandler(.failure(ScanningError.codeNotFound))
                        }
                    }
                    return
                }

                DispatchQueue.main.async {
                    completionHandler(.success(
                        .init(
                            result: parsedResult,
                            boundingRects: getScannedBoundingRects(
                                from: results,
                                validLines: validatedResult
                            )
                        )
                    ))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }

    private func getScannedBoundingRects(
        from results: TextRecognizerResults,
        validLines: ValidatedResults
    ) -> ScannedBoundingRects {
        let allBoundingRects = results.map { $0.key }
        let validRectIndexes = validLines.map { $0.index }
        let validRects = allBoundingRects.enumerated()
            .filter { validRectIndexes.contains($0.offset) }
            .map { $0.element }
        let invalidRects = allBoundingRects.enumerated()
            .filter { !validRectIndexes.contains($0.offset) }
            .map { $0.element }

        return (validRects, invalidRects)
    }
}
