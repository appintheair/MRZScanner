//
//  File.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import CoreGraphics

public struct ScanningResult<T> {
    let result: T
    let boundingRects: (valid: [CGRect], invalid: [CGRect])
}
