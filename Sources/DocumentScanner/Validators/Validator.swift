//
//  Validator.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

public typealias ValidatedResult = [String: Int]

protocol Validator {
    func validLines(from possibleLines: [[String]]) -> ValidatedResult
}
