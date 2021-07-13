//
//  Scanner.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreImage

typealias ScannedResult = [CGRect : [String]]

protocol Scanner {
    /// Starts scanning
    /// - Parameters:
    ///   - pixelBuffer: Image.
    ///   - orientation: Image orientation.
    ///   - regionOfInterest: Only run on the region of interest for maximum speed.
    ///   - minimumTextHeight: The minimum height, relative to the image height, of the text to recognize.
    ///   - recognitionLevel: A value that determines whether the request prioritizes accuracy or speed in text recognition.
    ///   - foundBoundingRectsHandler: Passes all found text bounding rects in region of interest.
    ///   - completionHandler: Passes the result of a scan.
    func scan(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        regionOfInterest: CGRect?,
        minimumTextHeight: Float?,
        recognitionLevel: RecognitionLevel,
        requestCompletionHandler: @escaping (Result<ScannedResult, Error>) -> Void
    )
}
