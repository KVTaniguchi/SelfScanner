//
//  TextRecognizer.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/5/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import Foundation
import Vision
import VisionKit
import SwiftUI

/// this is a publisher
public struct TextRecognizer {
    var recognizedText: RecognizedText
    
    let sequenceHandler = VNSequenceRequestHandler()
    
    func recognizeText(fromBuffer buffer: CVImageBuffer) {
        var tmp = ""
        
        let req = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // Concatenate the recognised text from all the observations.
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                tmp += candidate.string + "\n"
            }
            self.recognizedText.value = tmp
        }
        req.recognitionLanguages = ["en-us"]
        do {
            try sequenceHandler.perform([req], on: buffer)
        } catch {
            print(error)
        }
    }
    
    func textDetection(rectObservation: VNRectangleObservation, searchTerm: String) -> VNRecognizeTextRequest {
        let textDetection = VNRecognizeTextRequest { (request, error) in

            guard let textObservations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // Concatenate the recognised text from all the observations.
            let maximumCandidates = 10
            for textObservation in textObservations {
                guard let candidate = textObservation.topCandidates(maximumCandidates).first else { continue }
                
                guard candidate.string.lowercased().contains(searchTerm.lowercased()) else { continue }

//                let objectBounds = VNImageRectForNormalizedRect(rectObservation.boundingBox, Int(bufferSize.width), Int(sself.bufferSize.height))
//
//                let shapeLayer = sself.createRoundedRectLayerWithBounds(objectBounds)
//
//                let textLayer = sself.createTextSubLayerInBounds(objectBounds,
//                                                                 identifier: candidate.string,
//                                                                confidence: textObservation.confidence)
//
//                let fadeAnimation = CABasicAnimation(keyPath: "opacity")
//                fadeAnimation.fromValue = 1
//                fadeAnimation.toValue = 0
//                fadeAnimation.duration = 4.0
//                fadeAnimation.isRemovedOnCompletion = true
//                shapeLayer.add(fadeAnimation, forKey: nil)
//
//                shapeLayer.addSublayer(textLayer)
//                sself.detectionOverlay.addSublayer(shapeLayer)
//                playHaptic()
            }
        }
        
        return textDetection
    }
    
}


