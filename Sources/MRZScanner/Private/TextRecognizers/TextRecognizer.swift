//
//  Recognizer.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

struct TextRecognizerResult {
    let results: [String]
    let boundingRect: CGRect
}

protocol TextRecognizer {
    func recognize(
        scanningImage: ScanningImage,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        completionHandler: @escaping (Result<[TextRecognizerResult], Error>) -> Void
    )
}
