//
//  MRZLineParser.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import MRZParser

// TODO: Remove this line when `DocumentScanningResult` will be implemented
typealias ParsedResult = MRZResult

struct MRZLineParser: Parser {
    public init() {}

    public func parse(lines: [String]) -> ParsedResult? {
        MRZParser().parse(mrzLines: lines)
    }
}
