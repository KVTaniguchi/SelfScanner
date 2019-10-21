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
    
    typealias UIViewControllerType = CameraLayerViewController
    
    func makeCoordinator() -> MyCoordinator {
        return MyCoordinator(recognizedItemPublisher: recognizedItemPublisher)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewPort>) -> CameraLayerViewController {
        let vc = CameraLayerViewController()
        vc.sampleOutputDelegate = context.coordinator
        context.coordinator.itemRecognizer.delegate = vc
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraLayerViewController,
                                context: UIViewControllerRepresentableContext<ViewPort>) { }
}

class MyCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//    let textRecognizer: TextRecognizer
    var itemRecognizer: ItemRecognizer
    
    init(recognizedItemPublisher: RecognizedItemPublisher) {
//        textRecognizer = TextRecognizer(recognizedText: recognizedText)
        itemRecognizer = ItemRecognizer(recognizedItemPublisher: recognizedItemPublisher)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return
        }
        
        itemRecognizer.recognizedItem(fromBuffer: imageBuffer)
//        textRecognizer.recognizeText(fromBuffer: imageBuffer)
    }
}
