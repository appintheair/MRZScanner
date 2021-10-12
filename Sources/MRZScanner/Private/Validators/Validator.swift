//
//  Validator.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

typealias ValidatedResults = [ValidatedResult]
struct ValidatedResult {
    /// MRZLine
    let result: String
    /// MRZLine boundingRect index
    let index: Int
}

protocol Validator {
    func getValidatedResults(from possibleLines: [[String]]) -> ValidatedResults
}
