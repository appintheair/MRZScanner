//
//  MRZValidator.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import MRZParser

struct MRZValidator: Validator {
    func validLines(from possibleLines: [[String]]) -> ValidatedResult {
        let lineLengthAndLinesCount = [TD2.lineLength: 2, TD3.lineLength: 2, TD1.lineLength : 3]

        /// Key is MRZLine, value is bouningRect index
        var validLines = [String: Int]()
        var currentLineCount = 2

        for (index, lines) in possibleLines.enumerated() {
            guard validLines.count < currentLineCount, let mostLikelyLine = lines.first(where: {
                if let firstLine = lines.first {
                    return firstLine.count == $0.count
                } else {
                    if let linesCount = lineLengthAndLinesCount[$0.count] {
                        currentLineCount = linesCount
                        return true
                    } else {
                        return false
                    }

                }
            }) else {
                continue
            }

            validLines[mostLikelyLine] = index
        }

        return validLines
    }
}
