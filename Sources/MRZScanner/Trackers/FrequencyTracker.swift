//
//  FrequencyTracker.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

final class FrequencyTracker: Tracker {
    private let frequency: Int
    private var seenResults: [ParsedResult: Int] = [:]

    init(frequency: Int) {
        self.frequency = frequency
    }

    func isResultStable(_ result: ParsedResult) -> Bool {
        guard let seenResultFrequency = seenResults[result] else {
            seenResults[result] = 1
            return false
        }

        guard seenResultFrequency + 1 < frequency else {
            seenResults = [:]
            return true
        }

        seenResults[result]? += 1
        return false
    }

    func reset() {

    }
}
