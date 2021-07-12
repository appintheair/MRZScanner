//
//  ScanningResult.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreGraphics

public struct ScanningResult<T> {
    public let result: T
    public let boundingRects: (valid: [CGRect], invalid: [CGRect])
}
