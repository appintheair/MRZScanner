//
//  ScanningImage.swift
//  ScanningImage
//
//  Created by Roman Mazeev on 28.07.2021.
//

import CoreImage

public enum ScanningImage {
    case cgImage(CGImage)
    case pixelBuffer(CVPixelBuffer)
}
