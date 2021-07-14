//
//  StubParser.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import DocumentScanner

struct StubParser: Parser {
    var parsedResult: ParsedResult?
    func parse(lines: [String]) -> ParsedResult? {
        parsedResult
    }
}
