//
//  StubTracker.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import MRZScanner

struct StubTracker: Tracker {
    var trackedResult: TrackedResult

    func track(result: ParsedResult, cleanOldAfter: Int?) -> TrackedResult { trackedResult }
    func reset() {}
}
