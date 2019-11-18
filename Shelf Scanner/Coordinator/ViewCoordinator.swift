//
//  ViewCoordinator.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 11/17/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import Foundation
import Vision
import VisionKit
import AVKit

class ViewCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var itemRecognizer: ItemRecognizer
    let searchTerm: String
    
    init(recognizedItemPublisher: RecognizedItemPublisher, searchTerm: String) {
        self.searchTerm = searchTerm
        itemRecognizer = ItemRecognizer(recognizedItemPublisher: recognizedItemPublisher)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return
        }
        
        itemRecognizer.recognizedItem(fromBuffer: imageBuffer)
    }
}
