//
//  StubTracker.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import MRZScanner

struct StubTracker: Tracker {
    var isResultStable = true
    func isResultStable(_ result: ParsedResult) -> Bool { isResultStable }
    func reset() {}
}
