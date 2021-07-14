//
//  Tracker.swift
//
//
//  Created by Roman Mazeev on 16.06.2021.
//

protocol Tracker {
    func isResultStable(_ result: ParsedResult) -> Bool
    func reset()
}
