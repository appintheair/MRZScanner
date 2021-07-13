//
//  StubParser.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import DocumentScanner

struct StubParser: Parser {
    func parse(lines: [String]) -> ParsedResult? { nil }
}
