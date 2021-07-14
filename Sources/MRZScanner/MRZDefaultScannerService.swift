//
//  MRZDefaultScannerService.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import Foundation

protocol MRZDefaultScannerService {
    var scanner: Scanner { get }
}

extension MRZDefaultScannerService {
    var scanner: Scanner {
        Scanner(
            textRecognizer: VisionTextRecognizer(),
            validator: MRZValidator(),
            parser: MRZLineParser()
        )
    }
}
