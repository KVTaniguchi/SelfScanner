//
//  RecognizedText.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/5/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import Combine
import SwiftUI
 
final class RecognizedText: ObservableObject {
 
    let didChange = PassthroughSubject<Any, Error>()
 
    var value: String = "Scan document to see its contents" {
        didSet {
            didChange.send(self)
        }
    }
}
