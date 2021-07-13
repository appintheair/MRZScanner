//
//  ManagerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import DocumentScanner

class DefaultManagerTests: XCTestCase {
    private var manager: Manager!

    override func setUp() {
        super.setUp()

        manager = DefaultManager()
    }
}
