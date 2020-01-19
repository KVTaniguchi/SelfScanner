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
import UIKit

class ItemRecognizer {
    var recognizedItemPublisher: RecognizedItemPublisher
    weak var delegate: VisionTrackerProcessorDelegate?
    let sequenceHandler = VNSequenceRequestHandler()
    let rectangleRequest = VNDetectRectanglesRequest()
    private var requests = [VNRequest]()
    
    private var initialRectObservations = [VNRectangleObservation]()
    
    init(recognizedItemPublisher: RecognizedItemPublisher) {
        self.recognizedItemPublisher = recognizedItemPublisher
        setupVision()
    }
    
    func setupVision() {
        rectangleRequest.minimumAspectRatio = VNAspectRatio(0.2)
        rectangleRequest.maximumAspectRatio = VNAspectRatio(1.0)
        rectangleRequest.minimumSize = Float(0.1)
        rectangleRequest.maximumObservations = Int(10)
        rectangleRequest.minimumConfidence = 0.9
        
        self.requests = [rectangleRequest]
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
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
        
        if let rectObservations = rectangleRequest.results as? [VNRectangleObservation], !rectObservations.isEmpty {
            for rectObservation in rectObservations {
                // do text detection?
                
                let image = extractPerspectiveRect(rectObservation, from: buffer)
                
                let textDetection = VNRecognizeTextRequest { [weak self] (request, error) in
                    guard let textObservations = request.results as? [VNRecognizedTextObservation], let sself = self else {
                        assertionFailure("The observations are of an unexpected type.")
                        return
                    }
                    // Concatenate the recognised text from all the observations.
                    let maximumCandidates = 10
                    for textObservation in textObservations {
                        guard let candidate = textObservation.topCandidates(maximumCandidates).first else { continue }

                        sself.delegate?.drawVisionRequestResults(rectObservation, text: candidate.string)
                    }
                }
                
                do {
                    try sequenceHandler.perform([textDetection], on: image)
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
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
}
