//
//  MRZScanner.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import MRZParser
import Vision

public class MRZScanner {
    private let parser = MRZParser()

    public init() {}

    /// Starts scanning
    /// - Parameters:
    ///   - pixelBuffer: Image.
    ///   - orientation: Image orientation
    ///   - regionOfInterest: Only run on the region of interest for maximum speed.
    ///   - minimumTextHeight: The minimum height of the text expected to be recognized, relative to the image height
    ///   - recognitionLevel: VNRequestTextRecognitionLevel
    ///   - foundBoundingRectsHandler: Passes all found text bounding rects in region of interest
    ///   - completionHandler: Passes the result of a scan
    public func scan(pixelBuffer: CVPixelBuffer,
                     orientation: CGImagePropertyOrientation,
                     regionOfInterest: CGRect,
                     minimumTextHeight: Float = 0.1,
                     recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
                     foundBoundingRectsHandler: (([CGRect]) -> Void)? = nil,
                     completionHandler: @escaping (Result<ScanningResult<MRZResult>, Error>) -> Void) {
        let request = createRequest(completionHandler: completionHandler, foundBoundingRectsHandler: foundBoundingRectsHandler)
        request.regionOfInterest = regionOfInterest
        request.minimumTextHeight = minimumTextHeight
        request.recognitionLevel = recognitionLevel
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                completionHandler(.failure(error))
            }
        }
    }


    private func createRequest(
        completionHandler: @escaping (Result<ScanningResult<MRZResult>, Error>) -> Void,
        foundBoundingRectsHandler: (([CGRect]) -> Void)?
    ) -> VNRecognizeTextRequest {
        let lineLengthAndLinesCount = [TD2.lineLength: 2, TD3.lineLength: 2, TD1.lineLength : 3]

        return VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard error == nil else {
                    completionHandler(.failure(error!))
                    return
                }

                let results = request.results as! [VNRecognizedTextObservation]

                /// Key is MRZLine, value is bouningRect index
                var lines = [String: Int]()
                var boundingRects = [CGRect]()
                var currentLineCount = 2

                for (index, visionResult) in results.enumerated() {
                    if lines.count < currentLineCount,
                       let mostLikelyLine = visionResult.topCandidates(10).map({ $0.string }).first(where: {
                           if let firstLine = lines.first {
                               return firstLine.key.count == $0.count
                           } else {
                               if let linesCount = lineLengthAndLinesCount[$0.count] {
                                   currentLineCount = linesCount
                                   return true
                               } else {
                                   return false
                               }

                           }
                       }) {
                        lines[mostLikelyLine] = index
                    }

                    boundingRects.append(visionResult.boundingBox)
                }

                foundBoundingRectsHandler?(boundingRects)

                if let result = self.parser.parse(mrzLines: lines.map { $0.key }) {
                    let validLinesRects = lines.map { boundingRects[$0.value] }
                    let invalidLinesRects = boundingRects.filter { !validLinesRects.contains($0) }
                    completionHandler(
                        .success(
                            .init(
                                result: result,
                                boundingRects: (validLinesRects, invalidLinesRects )
                            )
                        )
                    )
                } else {
                    completionHandler(.failure(MRZScannerError.codeNotFound))
                    return
                }
            }
        })
    }
}

enum MRZScannerError: Error {
    case codeNotFound
}
