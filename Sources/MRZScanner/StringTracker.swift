//
//  StringTracker.swift
//  
//
//  Created by Roman Mazeev on 16.06.2021.
//

import Foundation

class StringTracker {
    private typealias StringObservation = (lastSeen: Int, count: Int)
    private var frameIndex = 0

    /// Dictionary of seen strings. Used to get stable recognition before displaying anything.
    private var seenStrings = [String: StringObservation]()
    private var bestCount = 0
    private var bestString = ""

    func logFrame(string: String) {
        if seenStrings[string] == nil {
            seenStrings[string] = (lastSeen: 0, count: -1)
        }
        seenStrings[string]?.lastSeen = frameIndex
        seenStrings[string]?.count += 1

        var obsoleteStrings = [String]()

        // Go through strings and prune any that have not been seen in while.
        // Also find the (non-pruned) string with the greatest count.
        for (string, obs) in seenStrings {
            // Remove previously seen text after 30 frames (~1s).
            if obs.lastSeen < frameIndex - 30 {
                obsoleteStrings.append(string)
            }

            // Find the string with the greatest count.
            let count = obs.count
            if !obsoleteStrings.contains(string) && count > bestCount {
                bestCount = count
                bestString = string
            }
        }
        // Remove old strings.
        for string in obsoleteStrings {
            seenStrings.removeValue(forKey: string)
        }

        frameIndex += 1
    }

    var stableString: String? {
        // Require the recognizer to see the same string at least 5 times.
        bestCount >= 5 ? bestString : nil
    }

    func reset(string: String) {
        seenStrings.removeValue(forKey: string)
        bestCount = 0
        bestString = ""
    }
}

