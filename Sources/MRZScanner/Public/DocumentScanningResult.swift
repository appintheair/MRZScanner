//
//  DocumentScanningResult.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreGraphics

public typealias ScannedBoundingRects = (valid: [CGRect], invalid: [CGRect])

public struct DocumentScanningResult<T> {
    public let result: T
    public let boundingRects: ScannedBoundingRects
}
