//
//  StubModels.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import MRZScanner
import CoreImage

struct StubModels {
    static let firstParsedResultStub = ParsedResult(
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

    static let secondParsedResultStub = ParsedResult(
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

    static var sampleBufferStub: CVPixelBuffer {
        var pixelBuffer : CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        return pixelBuffer!
    }
}
