//
//  File.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import Foundation

struct DefaultManager: Manager {
    public init() {}

    public func merge(allBoundingRects: [CGRect], validRectIndexes: [Int]) -> ManagerResult {
        let invalidRects = allBoundingRects.enumerated()
            .filter { !validRectIndexes.contains($0.offset) }
            .map { $0.element }
        let validRects = validRectIndexes.map { allBoundingRects[$0] }
        return (validRects, invalidRects)
    }
}

