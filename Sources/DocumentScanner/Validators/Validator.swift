//
//  Validator.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

typealias ValidatedResults = [ValidatedResult]
struct ValidatedResult {
    let result: String
    let bouningRectIndex: Int
}

protocol Validator {
    func getValidatedResults(from possibleLines: [[String]]) -> ValidatedResults
}
