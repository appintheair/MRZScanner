//
//  DocumentScanningResult.swift
//  
//
//  Created by Roman Mazeev on 12.07.2021.
//

public struct LiveDocuemntScanningResult {
    let result: DocumentScanningResult<ParsedResult>
    let accuracy: Int
}

public struct DocumentScanningResult<T> {
    public let result: T
    public let boundingRects: ManagerResult
}
