//
//  StubTextRecognizer.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import MRZScanner
import CoreImage

struct StubTextRecognizer: TextRecognizer {
    var recognizeResult: Result<[TextRecognizerResult], Error>?
    func recognize(
        scanningImage: ScanningImage,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        completionHandler: @escaping (Result<[TextRecognizerResult], Error>) -> Void
    ) {
        if let recognizeResult = recognizeResult {
            completionHandler(recognizeResult)
        }
    }
}
