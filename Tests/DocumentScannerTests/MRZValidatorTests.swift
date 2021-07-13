//
//  MRZValidatorTests.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

import XCTest
@testable import DocumentScanner

final class MRZValidatorTests: XCTestCase {
    private var validator: Validator!
    override func setUp() {
        super.setUp()

        validator = MRZValidator()
    }
}
