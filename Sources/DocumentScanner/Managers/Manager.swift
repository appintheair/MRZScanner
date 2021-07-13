//
//  BoundingRectService.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import Foundation

public typealias ManagerResult = (validRects: [CGRect], invalidRects: [CGRect])

protocol Manager {
    func merge(allBoundingRects: [CGRect], validRectIndexes: [Int]) -> ManagerResult
}
