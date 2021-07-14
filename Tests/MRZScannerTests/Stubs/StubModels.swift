//
//  StubModels.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

@testable import MRZScanner
import CoreImage

struct StubModels {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return formatter
    }()

    static let firstParsedResult = ParsedResult(
        format: .td3,
        documentType: .passport,
        countryCode: "UTO",
        surnames: "ERIKSSON",
        givenNames: "ANNA MARIA",
        documentNumber: "L898902C3",
        nationalityCountryCode: "UTO",
        birthdate:  dateFormatter.date(from: "740812")!,
        sex: .female,
        expiryDate: dateFormatter.date(from: "120415")!,
        optionalData: "ZE184226B",
        optionalData2: nil
    )

    static let secondParsedResult = ParsedResult(
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

    static let textRecognizerResults = [CGRect(): [""]]
    static let validatedResults: [ValidatedResult] = [.init(result: "", index: 0)]

    static var sampleBufferStub: CVPixelBuffer {
        var pixelBuffer : CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        return pixelBuffer!
    }
}
