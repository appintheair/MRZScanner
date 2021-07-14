//
//  Validator.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

typealias ValidatedResults = [ValidatedResult]
struct ValidatedResult {
    let result: String
    let index: Int
}

protocol Validator {
    func getValidatedResults(from possibleLines: [[String]]) -> ValidatedResults
}
