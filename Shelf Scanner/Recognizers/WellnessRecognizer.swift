//
//  WellnessRecognizer.swift
import Foundation
import Combine
import SwiftUI
 
final class RecognizedText: ObservableObject {
    @Published var value: String {
        didSet {
            didChange.send()
        }
    }
    
    let didChange = PassthroughSubject<Void, Never>()
    
    init(value: String) {
        self.value = value
    }
}

final class RecognizedItemPublisher: ObservableObject {
    @Published var values: [ShelfItem] = [] {
        didSet {
            didChange.send()
        }
    }
    
    let didChange = PassthroughSubject<Void, Never>()
}
