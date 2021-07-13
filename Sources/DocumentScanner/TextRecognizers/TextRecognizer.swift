//
//  Recognizer.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

typealias TextRecognizerResults = [CGRect : [String]]

protocol TextRecognizer {
    func recognize(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        completionHandler: @escaping (Result<TextRecognizerResults, Error>) -> Void
    )
}
