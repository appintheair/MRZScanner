//
//  MRZValidator.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

struct MRZValidator: Validator {
    private struct MRZCode {
        let lineLength: Int
        let linesCount: Int
    }

    private let validMRZCodes = [
        // TD1
        MRZCode(lineLength: 30, linesCount: 3),
        // TD2
        MRZCode(lineLength: 36, linesCount: 2),
        // TD3
        MRZCode(lineLength: 44, linesCount: 2)
    ]

    func getValidatedResults(from possibleLines: [[String]]) -> ValidatedResults {
        /// Key is MRZLine, value is bouningRect index
        var validLines = ValidatedResults()

        for validMRZCode in validMRZCodes {
            guard validLines.count < validMRZCode.linesCount else { break }
            for (index, lines) in possibleLines.enumerated() {
                guard validLines.count < validMRZCode.linesCount else { break }
                guard let mostLikelyLine = lines.first(where: {
                    $0.count == validMRZCode.lineLength
                }) else { continue }
                validLines.append(.init(result: mostLikelyLine, index: index))
            }

            if validLines.count != validMRZCode.linesCount {
                validLines = []
            }
        }
        return validLines
    }
}
