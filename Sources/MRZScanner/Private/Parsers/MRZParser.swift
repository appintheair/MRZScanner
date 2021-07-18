//
//  MRZLineParser.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import MRZParser

// TODO: Remove this line when `ParsedResult` struct will be implemented
public typealias ParsedResult = MRZResult

struct MRZLineParser: Parser {
    func parse(lines: [String]) -> ParsedResult? {
        MRZParser(isOCRCorrectionEnabled: true).parse(mrzLines: lines)
    }
}
