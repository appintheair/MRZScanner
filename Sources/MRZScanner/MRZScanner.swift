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

/// Result of scanning
public enum ScanningResult {
    /// Successful scan result. `Accuracy` is the number of successfully recognized frames with this result
    case success(mrzResult: MRZResult, accuracy: Int)
    /// No MRZ code was detected on the scanned image
    case noValidMRZ
    /// An error occurred during the request execution
    case requestError(Error)
}

public class MRZScanner {
    private let parser = MRZParser()
    public let tracker = ResultTracker()
    public weak var delegate: MRZScannerDelegate?

    public init() {}


    /// Starts scanning
    /// - Parameters:
    ///   - pixelBuffer: Image.
    ///   - orientation: Image orientation
    ///   - regionOfInterest: Only run on the region of interest for maximum speed.
    ///   - minimumTextHeight: The minimum height of the text expected to be recognized, relative to the image height
    ///   - recognitionLevel: For live recording it is better to use `.fast` otherwise `.accurate`
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
        let linesCountWithLineLength = [2: [TD2.lineLength, TD3.lineLength], 3: [TD1.lineLength]]

        return VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                guard let self = self, let results = request.results as? [VNRecognizedTextObservation] else { return }
                guard let possibleLineLenth = linesCountWithLineLength[results.count] else {
                    self.delegate?.mrzScanner(self, didFindBoundingRects: [])
                    self.delegate?.mrzScanner(self, didReceiveResult: .noValidMRZ)
                    return
                }

                var codes = [String]()
                var boundingRects = [CGRect]()

                for visionResult in results {
                    let line = visionResult.topCandidates(10)
                        .map { $0.string }
                        .first(where: {
                            if let firstCode = codes.first {
                                return firstCode.count == $0.count
                            } else {
                                return possibleLineLenth.contains($0.count)
                            }
                        })

                    guard let line = line else {
                        self.delegate?.mrzScanner(self, didFindBoundingRects: [])
                        self.delegate?.mrzScanner(self, didReceiveResult: .noValidMRZ)
                        return
                    }

                    boundingRects.append(visionResult.boundingBox)
                    codes.append(line)
                }

                self.delegate?.mrzScanner(self, didFindBoundingRects: boundingRects)

                guard let result = self.parser.parse(mrzLines: codes) else {
                    self.delegate?.mrzScanner(self, didReceiveResult: .noValidMRZ)
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
