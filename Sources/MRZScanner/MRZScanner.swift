//
//  MRZScanner.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Vision
import MRZParser

public typealias ScanningResult = MRZResult

public protocol MRZScannerDelegate: AnyObject {
    func mrzScanner(_ scanner: MRZScanner, didFinishWith result: Result<ScanningResult, Error>)
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: (invalid: [CGRect], valid: [CGRect]))
}

public class MRZScanner {
    private var request: VNRecognizeTextRequest!
    private let tracker = StringTracker()
    private let parser = MRZParser(ocrCorrection: true)
    public weak var delegate: MRZScannerDelegate?

    public init() {
        request = .init(completionHandler: { [weak self] request, error in
            guard let self = self, let results = request.results as? [VNRecognizedTextObservation] else { return }
            var codes = [String]()
            /// Shows all recognized text lines
            var invalidRects = [CGRect]()
            /// Shows words that might be serials
            var validRects = [CGRect]()

            let maximumCandidates = 1
            for visionResult in results {
                guard let line = visionResult.topCandidates(maximumCandidates).first?.string else { continue }

                var numberIsSubstring = true

                if self.parser.isLineValid(line: line) {
                    codes.append(line)
                    numberIsSubstring = false

                    validRects.append(visionResult.boundingBox)
                }

                if numberIsSubstring {
                    invalidRects.append(visionResult.boundingBox)
                }
            }

            DispatchQueue.main.async {
                self.delegate?.mrzScanner(self, didFindBoundingRects: (invalid: invalidRects, valid: validRects))
            }

            // Log any found numbers.
            if [TD1.linesCount, TD2.linesCount, TD3.linesCount].contains(codes.count) {
                self.tracker.logFrame(string: codes.joined(separator: "\n"))
                
                // Check if we have any temporally stable numbers.
                if let sureNumber = self.tracker.stableString,
                   let result = self.parser.parse(mrzString: sureNumber),
                   result.allCheckDigitsValid {
                    DispatchQueue.main.async {
                        self.delegate?.mrzScanner(self, didFinishWith: .success(result))
                    }
                    self.tracker.reset(string: sureNumber)
                }
            }
        })

        // Configure for running in real-time.
        self.request.recognitionLevel = .fast
        self.request.minimumTextHeight = 0.1

        // Language correction won't help recognizing phone numbers. It also
        // makes recognition slower.
        self.request.usesLanguageCorrection = false
    }

    public func scan(pixelBuffer: CVPixelBuffer,
                     orientation: CGImagePropertyOrientation,
                     regionOfInterest: CGRect) {
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: [:])
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Only run on the region of interest for maximum speed.
            self.request.regionOfInterest = regionOfInterest

            do {
                try imageRequestHandler.perform([self.request])
            } catch {
                self.delegate?.mrzScanner(self, didFinishWith: .failure(error))
            }
        }
    }
}
