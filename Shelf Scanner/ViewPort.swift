//
//  ImagePicker.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/5/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import Foundation
import SwiftUI
import Vision
import VisionKit
import AVKit

struct ViewPort: UIViewControllerRepresentable {
    
    let recognizedItemPublisher = RecognizedItemPublisher()
    let searchTerm: String
    
    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }
    
    typealias UIViewControllerType = VisionObjectRecognitionViewController
    
    func makeCoordinator() -> ViewCoordinator {
        return ViewCoordinator(recognizedItemPublisher: recognizedItemPublisher, searchTerm: searchTerm)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewPort>) -> VisionObjectRecognitionViewController {
        let vc = VisionObjectRecognitionViewController(searchTerm: searchTerm)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VisionObjectRecognitionViewController,
                                context: UIViewControllerRepresentableContext<ViewPort>) { }
}
