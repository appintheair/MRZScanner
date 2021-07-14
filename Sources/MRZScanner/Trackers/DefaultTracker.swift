//
//  DefaultTracker.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

final class DefaultTracker: Tracker {
    private typealias ResultObservation = (lastSeen: Int, count: Int)

    /// Dictionary of seen results. Used to get stable recognition before displaying anything.
    private var seenMRZResults: [ParsedResult: ResultObservation] = [:]
    private var frameIndex = 0

    var bestResult: TrackedResult? {
        guard let mostProbableResult = seenMRZResults.sorted(by: { $0.value.count > $1.value.count }).first else {
            return nil
        }
        return (mostProbableResult.key, mostProbableResult.value.count)
    }

    func track(result: ParsedResult, cleanOldAfter: Int?) {
        if let secondsToClean = cleanOldAfter {
            seenMRZResults = seenMRZResults.filter { $0.value.lastSeen > frameIndex - secondsToClean * 30 }
        }

        if seenMRZResults[result] == nil {
            seenMRZResults[result] = (lastSeen: 0, count: 0)
        }

        seenMRZResults[result]?.lastSeen = frameIndex
        seenMRZResults[result]?.count += 1

        frameIndex += 1
    }

    func reset() {
        seenMRZResults = [:]
        frameIndex = 0
    }
}
