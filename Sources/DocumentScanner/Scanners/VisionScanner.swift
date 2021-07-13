//
//  VisionScanner.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import Vision

struct VisionScanner: Scanner {
    func scan(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        requestCompletionHandler: @escaping (Result<ScannedResult, Error>) -> Void
    ) {
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                requestCompletionHandler(.failure(error!))
                return
            }

            let visionResults = request.results as! [VNRecognizedTextObservation]

            var result: [CGRect : [String]] = [:]
            for visionResult in visionResults {
                result[visionResult.boundingBox] = visionResult.topCandidates(10).map { $0.string }
            }

            requestCompletionHandler(.success(result))
        }

        if let regionOfInterest = regionOfInterest {
            request.regionOfInterest = regionOfInterest
        }
        if let minimumTextHeight = minimumTextHeight {
            request.minimumTextHeight = minimumTextHeight
        }
        request.recognitionLevel = recognitionLevel == .fast ? .fast : .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                requestCompletionHandler(.failure(error))
            }
        }
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
}
