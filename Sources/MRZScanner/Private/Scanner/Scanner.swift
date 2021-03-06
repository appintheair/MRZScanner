//
//  Scanner.swift
//  
//
//  Created by Roman Mazeev on 13.07.2021.
//

import CoreImage

protocol Scanner {
    var textRecognizer: TextRecognizer { get }
    var validator: Validator { get }
    var parser: Parser { get }
}
