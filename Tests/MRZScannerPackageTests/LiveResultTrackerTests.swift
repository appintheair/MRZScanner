    import XCTest
    @testable import MRZScanner

    final class MRZParserPackageTests: XCTestCase {
        var liveResultTracker: LiveResultTracker!
        private let firstExampleMRZResult = ParserResult(
            format: .td3,
            documentType: .passport,
            countryCode: "",
            surnames: "",
            givenNames: "",
            documentNumber: nil,
            nationalityCountryCode: "",
            birthdate: nil,
            sex: .male,
            expiryDate: nil,
            optionalData: nil,
            optionalData2: nil
        )

        private let secondExampleMRZResult = ParserResult(
            format: .td2,
            documentType: .id,
            countryCode: "",
            surnames: "",
            givenNames: "",
            documentNumber: nil,
            nationalityCountryCode: "",
            birthdate: nil,
            sex: .male,
            expiryDate: nil,
            optionalData: nil,
            optionalData2: nil
        )

        override func setUp() {
            super.setUp()

            liveResultTracker = LiveResultTracker()
        }

        func testSingleResult() {
            checkInitialState()
            liveResultTracker.track(result: firstExampleMRZResult)
            let liveScanningResult = liveResultTracker.liveScanningResult
            XCTAssertEqual(liveScanningResult?.result, firstExampleMRZResult)
            XCTAssertEqual(liveScanningResult?.accuracy, 1)
        }

        func testTwoResults() {
            checkInitialState()
            liveResultTracker.track(result: firstExampleMRZResult)
            liveResultTracker.track(result: secondExampleMRZResult)
            liveResultTracker.track(result: firstExampleMRZResult)
            liveResultTracker.track(result: secondExampleMRZResult)
            liveResultTracker.track(result: firstExampleMRZResult)
            let liveScanningResult = liveResultTracker.liveScanningResult
            XCTAssertEqual(liveScanningResult?.result, firstExampleMRZResult)
            XCTAssertEqual(liveScanningResult?.accuracy, 3)
        }

        func testTwoResultsAfter30Frames() {
            checkInitialState()
            for _ in 0 ..< 36 {
                liveResultTracker.track(result: secondExampleMRZResult)
            }

            for _ in 0 ..< 31 {
                liveResultTracker.track(result: firstExampleMRZResult)
            }

            let liveScanningResult = liveResultTracker.liveScanningResult
            XCTAssertEqual(liveScanningResult?.result, firstExampleMRZResult)
            XCTAssertEqual(liveScanningResult?.accuracy, 31)
        }

        func testReset() {
            checkInitialState()
            liveResultTracker.track(result: firstExampleMRZResult)
            let liveScanningResult = liveResultTracker.liveScanningResult
            XCTAssertEqual(liveScanningResult?.result, firstExampleMRZResult)
            XCTAssertEqual(liveScanningResult?.accuracy, 1)
            liveResultTracker.reset()
            XCTAssertNil(liveResultTracker.liveScanningResult)
        }

        private func checkInitialState() {
            XCTAssertNil(liveResultTracker.liveScanningResult)
        }
    }

