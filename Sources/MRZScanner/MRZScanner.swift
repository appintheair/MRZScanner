//
//  MRZScanner.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Vision
import MRZParser

public protocol MRZScannerDelegate: AnyObject {
    func mrzScanner(_ scanner: MRZScanner, didReceiveResult result: ScanningResult)
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: [CGRect])
}

public extension MRZScannerDelegate {
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: [CGRect]) {}
}

public enum ScanningResult {
    case success(mrzResult: MRZResult, accuracy: Int)
    case stringIsNotValidMRZ
    case requestError(Error)
}

public class MRZScanner {
    private let parser = MRZParser()
    public let tracker = ResultTracker()
    public weak var delegate: MRZScannerDelegate?

    public init() {}

    public func scan(pixelBuffer: CVPixelBuffer,
                     orientation: CGImagePropertyOrientation,
                     regionOfInterest: CGRect,
                     minimumTextHeight: Float = 0.1,
                     recognitionLevel: VNRequestTextRecognitionLevel = .fast) {
        let request = createRequest()
        request.regionOfInterest = regionOfInterest
        request.minimumTextHeight = minimumTextHeight
        request.recognitionLevel = recognitionLevel
        request.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: [:])
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                try imageRequestHandler.perform([request])
            } catch {
                self.delegate?.mrzScanner(self, didReceiveResult: .requestError(error))
            }
        }
    }

    private func createRequest() -> VNRecognizeTextRequest {
        VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
            guard let self = self, let results = request.results as? [VNRecognizedTextObservation] else { return }
            var codes = [String]()
            var boundingRects = [CGRect]()
            for visionResult in results {
                guard let line = visionResult.topCandidates(1).first?.string else { continue }
                codes.append(line)
                boundingRects.append(visionResult.boundingBox)
            }

            DispatchQueue.main.async {
                self.delegate?.mrzScanner(self, didFindBoundingRects: boundingRects)

                guard let result = self.parser.parse(mrzLines: codes) else {
                    self.delegate?.mrzScanner(self, didReceiveResult: .stringIsNotValidMRZ)
                    return
                }

                let scanningResult = self.tracker.trackAndGetMostProbableResult(track: result)
                self.delegate?.mrzScanner(self, didReceiveResult: .success(
                    mrzResult: scanningResult.mrzResult, accuracy: scanningResult.accuracy)
                )
            }
        })
    }
}
