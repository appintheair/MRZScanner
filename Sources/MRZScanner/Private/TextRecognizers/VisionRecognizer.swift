//
//  VisionRecognizer.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import Vision

struct VisionTextRecognizer: TextRecognizer {
    func recognize(
        scanningImage: ScanningImage,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        completionHandler: @escaping (Result<[TextRecognizerResult], Error>) -> Void
    ) {
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completionHandler(.failure(error!))
                return
            }

            let visionResults = request.results as! [VNRecognizedTextObservation]

            let result: [TextRecognizerResult] = visionResults.map {
                .init(results: $0.topCandidates(10).map { $0.string }, boundingRect: $0.boundingBox)
            }

            completionHandler(.success(result))
        }

        if let regionOfInterest = regionOfInterest {
            request.regionOfInterest = regionOfInterest
        }
        if let minimumTextHeight = minimumTextHeight {
            request.minimumTextHeight = minimumTextHeight
        }
        request.recognitionLevel = recognitionLevel == .fast ? .fast : .accurate
        request.usesLanguageCorrection = false

        let imageRequestHandler: VNImageRequestHandler
        switch scanningImage {
        case .cgImage(let image):
            imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        case .pixelBuffer(let pixelBuffer):
            imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}
