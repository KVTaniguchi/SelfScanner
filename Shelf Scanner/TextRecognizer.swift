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
        do {
            try sequenceHandler.perform([req], on: buffer)
        } catch {
            print(error)
        }
    }
}

/// rectangles around sectors
/// "ar" like view
///
/// "
