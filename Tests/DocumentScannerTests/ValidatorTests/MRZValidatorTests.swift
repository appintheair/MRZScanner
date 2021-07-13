//
//  MRZValidatorTests.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

@testable import DocumentScanner

final class MRZValidatorTests: ValidatorTests<MRZValidator> {
    override func setUp() {
        super.setUp()

        validator = MRZValidator()
    }
}
