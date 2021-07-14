//
//  Scanner.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import CoreImage

struct Scanner {
    private let textRecognizer: TextRecognizer
    private let validator: Validator
    private var parser: Parser
    private var tracker: Tracker

    init(textRecognizer: TextRecognizer, validator: Validator, parser: Parser, tracker: Tracker) {
        self.textRecognizer = textRecognizer
        self.validator = validator
        self.parser = parser
        self.tracker = tracker
    }

    func scanLive(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        cleanOldAfter: Int? = 1,
        foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
        completionHandler: @escaping (Result<LiveDocuemntScanningResult, Error>) -> Void
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
                DispatchQueue.main.async {
                    foundBoundingRectsHandler?(results.map { $0.key })
                }
                let parsedAndValidatedResults = getParsedAndValidatedResults(from: results)
                guard let parsedResult = parsedAndValidatedResults.0 else { return }
                tracker.track(result: parsedResult, cleanOldAfter: cleanOldAfter)
                guard let bestResult = tracker.bestResult else { fatalError("bestResult should be here") }

                DispatchQueue.main.async {
                    completionHandler(
                        .success(.init(
                            result: .init(
                                result: bestResult.result,
                                boundingRects: getScannedBoundingRects(
                                    from: results,
                                    validLines: parsedAndValidatedResults.1
                                )
                            ),
                            accuracy: bestResult.accuracy
                        ))
                    )
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                }
            }
        }
    }

    func scanSingle(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect? = nil,
        minimumTextHeight: Float? = nil,
        recognitionLevel: RecognitionLevel = .accurate,
        completionHandler: @escaping (Result<DocumentScanningResult<ParsedResult>, Error>) -> Void
    ) {
        textRecognizer.recognize(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: recognitionLevel
        ) {
            switch $0 {
            case .success(let results):
                let parsedAndValidatedResults = getParsedAndValidatedResults(from: results)
                guard let parsedResult = parsedAndValidatedResults.0 else {
                    completionHandler(.failure(SingleScanningError.codeNotFound))
                    return
                }

                DispatchQueue.main.async {
                    completionHandler(.success(
                        .init(
                            result: parsedResult,
                            boundingRects: getScannedBoundingRects(
                                from: results,
                                validLines: parsedAndValidatedResults.1
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

    private func getParsedAndValidatedResults(
        from results: TextRecognizerResults
    ) -> (ParsedResult?, ValidatedResults) {
        let validLines = validator.getValidatedResults(from: results.map { $0.value })
        let parsedResult = parser.parse(lines: validLines.map { $0.result })

        return (parsedResult, validLines)
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

    private enum SingleScanningError: Error {
        case codeNotFound
    }
}
