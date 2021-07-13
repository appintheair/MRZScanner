//
//  Parser.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

// TODO: Add protocol `DocumentScanningResult` to use not only MRZ
//typealias ParsedResult = DocumentScanningResult

protocol Parser {
    func parse(lines: [String]) -> ParsedResult?
}
