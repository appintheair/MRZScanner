//
//  Parser.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

// TODO: Add `ParsedResult` to use not only MRZ

protocol Parser {
    func parse(lines: [String]) -> ParsedResult?
}
