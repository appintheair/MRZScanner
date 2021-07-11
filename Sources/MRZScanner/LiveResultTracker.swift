//
//  LiveResultTracker.swift
//
//
//  Created by Roman Mazeev on 16.06.2021.
//

import Foundation
import MRZParser

/// Needed for scanning documents in live mode. Allows you to control the accuracy of results when using multiple frames
class LiveResultTracker {
    private typealias ResultObservation = (lastSeen: Int, count: Int)

    /// Dictionary of seen results. Used to get stable recognition before displaying anything.
    private var seenMRZResults: [MRZResult: ResultObservation] = [:]
    private var frameIndex = 0

    var liveScanningResult: LiveScanningResult? {
        guard let mostProbableResult = seenMRZResults.sorted(by: {
            $0.value.count > $1.value.count
        }).first else { return nil }
        return (mostProbableResult.key, mostProbableResult.value.count)
    }

    func track(result: MRZResult) {
        // Remove old results (~1s)
        seenMRZResults = seenMRZResults.filter { $0.value.lastSeen > frameIndex - 30 }

        if seenMRZResults[result] == nil {
            seenMRZResults[result] = (lastSeen: 0, count: -1)
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
