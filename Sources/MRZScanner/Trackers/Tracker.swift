//
//  Tracker.swift
//
//
//  Created by Roman Mazeev on 16.06.2021.
//

typealias TrackedResult = (result: ParsedResult, accuracy: Int)

/// Needed for scanning documents in live mode. Allows you to control the accuracy of results when using multiple frames
protocol Tracker {
    /// Allows you to track `ParserResult` and give the best results for some time
    /// - Parameter result: Valid result.
    /// - Parameter cleanOldAfter: After how much time you need to clear the previous result. In seconds.
    func track(result: ParsedResult, cleanOldAfter: Int?) -> TrackedResult
    func reset()
}
