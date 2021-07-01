//
//  ResultTracker.swift
//
//
//  Created by Roman Mazeev on 16.06.2021.
//

import Foundation
import MRZParser

public class ResultTracker {
    private typealias ResultObservation = (lastSeen: Int, count: Int)
    private var frameIndex = 0

    /// Dictionary of seen results. Used to get stable recognition before displaying anything.
    private var seenResults = [MRZResult: ResultObservation]()
    private var mostProbableResultCount = 0
    private var mostProbableResult: MRZResult?

    func trackAndGetMostProbableResult(track result: MRZResult) -> (mrzResult: MRZResult, accuracy: Int) {
        if seenResults[result] == nil {
            seenResults[result] = (lastSeen: 0, count: -1)
        }
        seenResults[result]?.lastSeen = frameIndex
        seenResults[result]?.count += 1

        var obsoleteResults = [MRZResult]()

        // Go through strings and prune any that have not been seen in while.
        // Also find the (non-pruned) results with the greatest count.
        for (result, obs) in seenResults {
            // Remove previously seen result after 30 frames (~1s).
            if obs.lastSeen < frameIndex - 30 {
                obsoleteResults.append(result)
            }

            // Find the result with the greatest count.
            let count = obs.count
            if !obsoleteResults.contains(result) {
                mostProbableResultCount = count
                mostProbableResult = result
            }
        }
        // Remove old results.
        for result in obsoleteResults {
            seenResults.removeValue(forKey: result)
        }

        frameIndex += 1

        guard let mostProbableResult = mostProbableResult else { fatalError("mostProbableResult have to be") }
        return (mostProbableResult, mostProbableResultCount)
    }

    public func reset(result: MRZResult) {
        seenResults.removeValue(forKey: result)
        mostProbableResultCount = 0
        mostProbableResult = nil
    }
}

extension MRZResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(format)
        hasher.combine(documentType)
        hasher.combine(countryCode)
        hasher.combine(surnames)
        hasher.combine(givenNames)
        hasher.combine(documentNumber)
        hasher.combine(nationalityCountryCode)
        hasher.combine(birthdate)
        hasher.combine(sex)
        hasher.combine(expiryDate)
        hasher.combine(optionalData)
        hasher.combine(optionalData2)
    }
}
