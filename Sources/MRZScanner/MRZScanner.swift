//
//  MRZScanner.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Vision
import MRZParser

/// Scan result and its accuracy based on frequency of occurrence
public typealias LiveScanningResult = (mrzResult: MRZResult, accuracy: Int)

public protocol MRZScannerDelegate: AnyObject {
    /// Passes the result of the scan
    func mrzScanner(_ scanner: MRZScanner, didReceiveResult result: ScanningResult)
    /// Passes the bounding rects of mrz strings
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: [CGRect])
}

public extension MRZScannerDelegate {
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: [CGRect]) {}
}

/// Result of scanning
public enum ScanningResult {
    /// Successful scan result using live capture. `Accuracy` is the number of successfully recognized frames with this result
    case liveSuccess(LiveScanningResult)
    /// Successful scan when `!isLive`.
    case imageSuccess(MRZResult: MRZResult)
    /// No MRZ code was detected on the scanned image
    case noValidMRZ
    /// An error occurred during the request execution
    case requestError(Error)
}

public class MRZScanner {
    public weak var delegate: MRZScannerDelegate?

    private let parser = MRZParser()
    private let liveResultTracker = LiveResultTracker()

    public init() {}


    /// Starts scanning
    /// - Parameters:
    ///   - pixelBuffer: Image.
    ///   - orientation: Image orientation
    ///   - regionOfInterest: Only run on the region of interest for maximum speed.
    ///   - isLive: Needed to set the `recognitionLevel` of the Vision request and  for `LiveResultTracker` using
    ///   - minimumTextHeight: The minimum height of the text expected to be recognized, relative to the image height
    public func scan(pixelBuffer: CVPixelBuffer,
                     orientation: CGImagePropertyOrientation,
                     regionOfInterest: CGRect,
                     isLive: Bool = false,
                     minimumTextHeight: Float = 0.1) {
        let request = createRequest(isLive: isLive)
        request.regionOfInterest = regionOfInterest
        request.minimumTextHeight = minimumTextHeight
        request.recognitionLevel = isLive ? .fast : .accurate
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

    /// Resets `LiveResultTracker` state
    public func resetLiveScanningSession() {
        liveResultTracker.reset()
    }

    private func createRequest(isLive: Bool) -> VNRecognizeTextRequest {
        let linesCountWithLineLength = [2: [TD2.lineLength, TD3.lineLength], 3: [TD1.lineLength]]

        return VNRecognizeTextRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard error == nil else {
                    self.delegate?.mrzScanner(self, didReceiveResult: .requestError(error!))
                    return
                }

                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                guard let possibleLineLenth = linesCountWithLineLength[results.count] else {
                    self.delegate?.mrzScanner(self, didFindBoundingRects: [])
                    self.delegate?.mrzScanner(self, didReceiveResult: .noValidMRZ)
                    return
                }

                var codes = [String]()
                var boundingRects = [CGRect]()

                for visionResult in results {
                    guard let line = visionResult.topCandidates(10).map({ $0.string }).first(where: {
                        if let firstCode = codes.first {
                            return firstCode.count == $0.count
                        } else {
                            return possibleLineLenth.contains($0.count)
                        }
                    }) else {
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

                if isLive {
                    self.liveResultTracker.track(result: result)
                    guard let liveScanningResult = self.liveResultTracker.liveScanningResult else {
                        fatalError("liveScanningResult must be set")
                    }

                    self.delegate?.mrzScanner(self, didReceiveResult: .liveSuccess(liveScanningResult))
                } else {
                    self.delegate?.mrzScanner(self, didReceiveResult: .imageSuccess(MRZResult: result))
                }
            }
        })
    }
}
