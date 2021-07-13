//
//  DefaultManagerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

@testable import DocumentScanner

final class DefaultManagerTests: ManagerTests<DefaultManager> {
    override func setUp() {
        super.setUp()

        manager = DefaultManager()
    }
}
