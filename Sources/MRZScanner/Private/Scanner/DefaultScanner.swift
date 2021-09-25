//
//  DefaultScanner.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import CoreImage

struct DefaultScanner: Scanner {
    enum ScanningError: Error {
        case codeNotFound
    }

    enum ScanningType {
        case live
        case single
    }

    let textRecognizer: TextRecognizer
    let validator: Validator
    let parser: Parser

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser) {
        self.textRecognizer = textRecognizer
        self.validator = validator
        self.parser = parser
    }

    func scan(
        scanningType: ScanningType,
        scanningImage: ScanningImage,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        textRecognizer.recognize(
            scanningImage: scanningImage,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: recognitionLevel
        ) {
            switch $0 {
            case .success(let results):
                DispatchQueue.main.async {
                    foundBoundingRectsHandler?(results.map { $0.boundingRect })
                }

                let validatedResult = validator.getValidatedResults(from: results.map { $0.results })
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
        from results: [TextRecognizerResult],
        validLines: ValidatedResults
    ) -> ScannedBoundingRects {
        let allBoundingRects = results.map(\.boundingRect)
        let validRectIndexes = Set(validLines.map(\.index))

        var scannedBoundingRects: ScannedBoundingRects = ([], [])
        allBoundingRects.enumerated().forEach {
            if validRectIndexes.contains($0.offset) {
                scannedBoundingRects.valid.append($0.element)
            } else {
                scannedBoundingRects.invalid.append($0.element)
            }
        }

        return scannedBoundingRects
    }
}

