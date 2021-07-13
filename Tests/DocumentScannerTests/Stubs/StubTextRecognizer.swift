//
//  StubTextRecognizer.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import DocumentScanner
import CoreImage

struct StubTextRecognizer: TextRecognizer {
    func recognize(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        completionHandler: @escaping (Result<TextRecognizerResults, Error>) -> Void
    ) {}

    func getValidatedResults(from possibleLines: [[String]]) -> ValidatedResults { [] }
}
