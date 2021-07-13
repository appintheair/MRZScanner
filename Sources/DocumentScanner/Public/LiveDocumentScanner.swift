//
//  LiveDocumentScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

public struct LiveDocumentScanner {
    private let scanner: Scanner
    private let validator: Validator
    private let parser: Parser
    private let manager: Manager
    private let tracker: Tracker

    // TODO: Add `Configuraton` struct
    public init() {
        scanner = VisionScanner()
        validator = MRZValidator()
        parser = MRZLineParser()
        manager = DefaultManager()
        tracker = DefaultTracker()
    }

    init(scanner: Scanner, validator: Validator, parser: Parser, manager: Manager, tracker: Tracker) {
        self.scanner = scanner
        self.validator = validator
        self.parser = parser
        self.manager = manager
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
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: .fast
        ) {
            switch $0 {
            case .success(let results):
                let validLines = validator.getValidatedResults(from: results.map { $0.value })
                guard let parserResult = parser.parse(lines: validLines.map { $0.result }) else { return }
                tracker.track(result: parserResult, cleanOldAfter: cleanOldAfter)
                guard let bestResult = tracker.bestResult else { fatalError("bestResult should be here") }
                let managerResult = manager.merge(
                    allBoundingRects: results.map { $0.key }, validRectIndexes: validLines.map { $0.bouningRectIndex }
                )
                completionHandler(
                    .success(.init(
                        result: .init(
                            result: bestResult.result,
                            boundingRects: managerResult
                        ),
                        accuracy: bestResult.accuracy
                    ))
                )
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
