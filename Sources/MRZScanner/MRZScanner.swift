//
//  MRZScannerViewController.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Vision
import MRZParser

public protocol MRZScannerDelegate: AnyObject {
    func mrzScanner(_ scanner: MRZScanner, didReciveResult result: MRZResult)
    func mrzScanner(_ scanner: MRZScanner, didReciveError error: Error)
}

public class MRZScanner {
    private var request: VNRecognizeTextRequest!
    private let mrzTracker = StringTracker()
    private let mrzParser = MRZParser(ocrCorrection: true)
    public weak var delegate: MRZScannerDelegate?
    private var isScanning = false

    public init() {
        request = .init(completionHandler: { [weak self] request, error in
            guard let self = self else { return }
            var codes = [String]()

            guard let results = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let maximumCandidates = 1
            for visionResult in results {
                guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }

                if let result = candidate.string.checkMrz() {
                    if(result != "nil"){
                        codes.append(result)
                    }
                }
            }

            // Log any found numbers.
            self.mrzTracker.logFrame(strings: codes)

            // Check if we have any temporally stable numbers.
            if let sureNumber = self.mrzTracker.getStableString(),
               let result = self.mrzParser.parse(mrzString: sureNumber) {
                self.delegate?.mrzScanner(self, didReciveResult: result)
                self.mrzTracker.reset(string: sureNumber)
            }

            self.isScanning = false
        })
    }

    public func scanImage(image: CGImage) {
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: .right, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, !self.isScanning else { return }
            do {
                try imageRequestHandler.perform([self.request])
                self.isScanning = true
            } catch let error {
                self.delegate?.mrzScanner(self, didReciveError: error)
            }
        }
    }
}
