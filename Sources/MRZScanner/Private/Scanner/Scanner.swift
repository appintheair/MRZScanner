//
//  Scanner.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import CoreImage

protocol Scanner {
    var textRecognizer: TextRecognizer { get set }
    var validator: Validator { get set }
    var parser: Parser { get set }
}
