//
//  File.swift
//  
//
//  Created by Roman Mazeev on 14.07.2021.
//

import Foundation

import DocumentScanner

struct StubModels {
    static let firstExampleParsedResult = ParsedResult(
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

    static let secondExampleParsedResult = ParsedResult(
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
}
