//
//  ScannerTests.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import XCTest
@testable import DocumentScanner

final class ScannerTests: XCTestCase {
    private var scanner: DocumentScanner.Scanner!

    override func setUp() {
        super.setUp()

        scanner = DocumentScanner.Scanner(
            textRecognizer: StubTextRecognizer(),
            validator: StubValidator(),
            parser: StubParser(),
            tracker: StubTracker()
        )
    }

    func testSingle() {
    }
}
