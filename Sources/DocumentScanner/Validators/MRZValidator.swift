//
//  MRZValidator.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import MRZParser

// TODO: At the moment passes once on the array, need to improve
struct MRZValidator: Validator {
    func getValidatedResults(from possibleLines: [[String]]) -> ValidatedResults {
        let validLineLength = [TD2.lineLength: 2, TD3.lineLength: 2, TD1.lineLength : 3]

        /// Key is MRZLine, value is bouningRect index
        var validLines = ValidatedResults()
        var currentLinesCount = 2

        for (index, lines) in possibleLines.enumerated() {
            guard let mostLikelyLine = lines.first(where: {
                if let firstLine = validLines.first, index < currentLinesCount {
                    return firstLine.result.count == $0.count
                } else {
                    if let linesCount = validLineLength[$0.count] {
                        currentLinesCount = linesCount
                        return true
                    } else {
                        return false
                    }

                }
            }) else {
                continue
            }

            validLines.append(.init(result: mostLikelyLine, index: index))
        }

        return validLines
    }
}
