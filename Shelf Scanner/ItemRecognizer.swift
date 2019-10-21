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

struct ItemRecognizer {
    var recognizedItemPublisher: RecognizedItemPublisher
    weak var delegate: VisionTrackerProcessorDelegate?
    
    let sequenceHandler = VNSequenceRequestHandler()
    
    private var initialRectObservations = [VNRectangleObservation]()
    
    init(recognizedItemPublisher: RecognizedItemPublisher) {
        self.recognizedItemPublisher = recognizedItemPublisher
    }
    
    mutating func recognizedItem(fromBuffer buffer: CVImageBuffer) {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
        rectangleDetectionRequest.minimumAspectRatio = VNAspectRatio(0.2)
        rectangleDetectionRequest.maximumAspectRatio = VNAspectRatio(1.0)
        rectangleDetectionRequest.minimumSize = Float(0.1)
        rectangleDetectionRequest.maximumObservations = Int(10)
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up, options: [:])
        
        do {
            try imageRequestHandler.perform([rectangleDetectionRequest])
        } catch {
//            throw VisionTrackerProcessorError.rectangleDetectionFailed
        }
        
        var firstFrameRects: [TrackedPolyRect]? = nil
        if let rectObservations = rectangleDetectionRequest.results as? [VNRectangleObservation] {
            initialRectObservations = rectObservations
            var detectedRects = [TrackedPolyRect]()
            var trackers = [VNTrackRectangleRequest]()
            for (index, rectangleObservation) in rectObservations.enumerated() {
                
                let rectColor = TrackedObjectsPalette.color(atIndex: index)
                detectedRects.append(TrackedPolyRect(observation: rectangleObservation, color: rectColor))
                // show frame
                let tracker = VNTrackRectangleRequest(rectangleObservation: rectangleObservation)
                trackers.append(tracker)
            }
            firstFrameRects = detectedRects
            
            // Perform array of requests
           do {
            try sequenceHandler.perform(trackers, on: buffer)
           } catch {
//               trackingFailedForAtLeastOneObject = true
           }

           var rects = [TrackedPolyRect]()
           for processedRequest in trackers {
               guard let results = processedRequest.results as? [VNObservation] else {
                   continue
               }
               guard let observation = results.first as? VNDetectedObjectObservation else {
                   continue
               }
               // Assume threshold = 0.5f
            let rectStyle: TrackedPolyRectStyle = observation.confidence > 0.5 ? .solid : .dashed
//               let knownRect = trackedObjects[observation.uuid]!
            let tracked = TrackedPolyRect(observation: observation, color: .yellow)
            rects.append(tracked)
               // Initialize inputObservation for the next iteration
//               inputObservations[observation.uuid] = observation
           }

           // Draw results
            for rect in rects {
                print(rect)
            }
//           delegate?.displayFrame(buffer, withAffineTransform: videoReader.affineTransform, rects: rects)
        }
        
        
        // get a rectangle
        // run text recognizer on the thing from a rectangle
        // run wellness recognizer on thing from a rectangle
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
    func displayFrame(_ frame: CVPixelBuffer?, withAffineTransform transform: CGAffineTransform, rects: [TrackedPolyRect]?)
    func displayFrameCounter(_ frame: Int)
}
