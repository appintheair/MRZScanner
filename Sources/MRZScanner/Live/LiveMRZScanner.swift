//
//  LiveMRZScanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import Vision
import MRZParser

public typealias LiveScanningResult = (result: MRZResult, accuracy: Int)

public protocol LiveMRZScannerDelegate: AnyObject {
    func liveMRZScanner(_ scanner: LiveMRZScanner,
                        didReceiveResult result: Result<ScanningResult<LiveScanningResult>, Error>)
}

public class LiveMRZScanner: MRZScanner {
    public weak var delegate: LiveMRZScannerDelegate?
    private let liveResultTracker = LiveResultTracker()
    private let mrzScanner = MRZScanner()

    public override init() {}

    public func scanFrame(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect,
        minimumTextHeight: Float = 0.1
    ) {
        mrzScanner.scan(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            regionOfInterest: regionOfInterest,
            minimumTextHeight: minimumTextHeight,
            recognitionLevel: .fast
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let scanningResult):
                self.liveResultTracker.track(result: scanningResult.result)
                guard let liveScanningResult = self.liveResultTracker.liveScanningResult else {
                    fatalError("liveScanningResult must be set")
                }
                self.delegate?.liveMRZScanner(
                    self,
                    didReceiveResult: .success(
                        .init(
                            result: liveScanningResult,
                            boundingRects: scanningResult.boundingRects
                        )
                    )
                )
            case .failure(let error):
                if error is MRZScannerError {
                    return
                } else {
                    self.delegate?.liveMRZScanner(self, didReceiveResult: .failure(error))
                }
            }
        }
    }

    /// Resets `LiveResultTracker` state
    public func resetLiveScanningSession() {
        liveResultTracker.reset()
    }
}
