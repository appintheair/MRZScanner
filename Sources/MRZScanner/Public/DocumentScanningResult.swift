//
//  DocumentScanningResult.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreGraphics

public struct LiveDocuemntScanningResult {
    public let result: DocumentScanningResult<ParsedResult>
    public let accuracy: Int
}

public typealias ScannedBoundingRects = (valid: [CGRect], invalid: [CGRect])

public struct DocumentScanningResult<T> {
    public let result: T
    public let boundingRects: ScannedBoundingRects
}
