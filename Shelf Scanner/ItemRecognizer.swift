//
//  ItemRecognizer.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/20/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import Foundation
import Vision
import VisionKit

class ItemRecognizer {
    var recognizedItemPublisher: RecognizedItemPublisher
    weak var delegate: VisionTrackerProcessorDelegate?
    
    let sequenceHandler = VNSequenceRequestHandler()
    
    private var initialRectObservations = [VNRectangleObservation]()
    
    init(recognizedItemPublisher: RecognizedItemPublisher) {
        self.recognizedItemPublisher = recognizedItemPublisher
    }
    
    func extractPerspectiveRect(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> CIImage {
        // get the pixel buffer into Core Image
        let ciImage = CIImage(cvImageBuffer: buffer)

        // convert corners from normalized image coordinates to pixel coordinates
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)

        // pass those to the filter to extract/rectify the image
        return ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
    }
    
    func recognizedItem(fromBuffer buffer: CVImageBuffer) {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
        rectangleDetectionRequest.minimumAspectRatio = VNAspectRatio(0.2)
        rectangleDetectionRequest.maximumAspectRatio = VNAspectRatio(1.0)
        rectangleDetectionRequest.minimumSize = Float(0.1)
        rectangleDetectionRequest.maximumObservations = Int(10)
        rectangleDetectionRequest.minimumConfidence = 0.9
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
        
        do {
            try imageRequestHandler.perform([rectangleDetectionRequest])
        } catch {
            print(error.localizedDescription)
        }
        
        if let rectObservations = rectangleDetectionRequest.results as? [VNRectangleObservation], !rectObservations.isEmpty {
            initialRectObservations = rectObservations

            for rectangleObservation in rectObservations {
                
                let textDetection = VNRecognizeTextRequest { [weak self] (request, error) in
                    guard let textObservations = request.results as? [VNRecognizedTextObservation] else {
                        print("The observations are of an unexpected type.")
                        return
                    }
                    // Concatenate the recognised text from all the observations.
                    let maximumCandidates = 1
                    for observation in textObservations {
                        guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                        // a rect that contains text
//                        self?.delegate?.drawVisionRequestResults(rect, text: candidate.string)
                        self?.delegate?.drawVisionRequestResults(rectangleObservation, text: candidate.string)
                    }
                }
                
                let extractedImage = extractPerspectiveRect(rectangleObservation, from: buffer)
                do {
                    try sequenceHandler.perform([textDetection], on: extractedImage)
                }
                catch {
                    print(error)
                }
                
            }
        } else {
            delegate?.drawVisionRequestResults(nil, text: nil)
        }
    }
}

enum VisionTrackerProcessorError: Error {
    case readerInitializationFailed
    case firstFrameReadFailed
    case objectTrackingFailed
    case rectangleDetectionFailed
}

struct TrackedObjectsPalette {
    static var palette = [
        UIColor.green,
        UIColor.cyan,
        UIColor.orange,
        UIColor.brown,
        UIColor.darkGray,
        UIColor.red,
        UIColor.yellow,
        UIColor.magenta,
        #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1), // light green
        UIColor.gray,
        UIColor.purple,
        UIColor.clear,
        #colorLiteral(red: 0, green: 0.9800859094, blue: 0.941437602, alpha: 1),   // light blue
        UIColor.lightGray,
        UIColor.black,
        UIColor.blue
    ]
    
    static func color(atIndex index: Int) -> UIColor {
        if index < palette.count {
            return palette[index]
        }
        return randomColor()
    }
    
    static func randomColor() -> UIColor {
        func randomComponent() -> CGFloat {
            return CGFloat(arc4random_uniform(256)) / 255.0
        }
        return UIColor(red: randomComponent(), green: randomComponent(), blue: randomComponent(), alpha: 1.0)
    }
}

protocol VisionTrackerProcessorDelegate: class {
    func drawVisionRequestResults(_ rectangleObservation: VNRectangleObservation?, text: String?)
    func displayFrameCounter(_ frame: Int)
}

extension CGPoint {
   func scaled(to size: CGSize) -> CGPoint {
       return CGPoint(x: self.x * size.width,
                      y: self.y * size.height)
   }
}
