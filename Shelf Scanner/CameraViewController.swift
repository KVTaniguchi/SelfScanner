//
//  CameraViewController.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/20/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

final class CameraLayerViewController: UIViewController {
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var sampleOutputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    let dataOutputQueue = DispatchQueue(
    label: "video data queue",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCaptureSession()
        session.startRunning()
    }
    
    func configureCaptureSession() {
      // Define the capture device we want to use
      guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .back) else {
        fatalError("No front video camera available")
      }
      
      // Connect the camera to the capture session input
      do {
        let cameraInput = try AVCaptureDeviceInput(device: camera)
        session.addInput(cameraInput)
      } catch {
        fatalError(error.localizedDescription)
      }
      
      // Create the video data output
      let videoOutput = AVCaptureVideoDataOutput()
      videoOutput.setSampleBufferDelegate(sampleOutputDelegate, queue: dataOutputQueue)
      videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
      
      // Add the video output to the capture session
      session.addOutput(videoOutput)
      
      let videoConnection = videoOutput.connection(with: .video)
      videoConnection?.videoOrientation = .portrait
      
      // Configure the preview layer
      previewLayer = AVCaptureVideoPreviewLayer(session: session)
      previewLayer.videoGravity = .resizeAspectFill
      previewLayer.frame = view.bounds
      view.layer.insertSublayer(previewLayer, at: 0)
    }
}

extension CameraLayerViewController: VisionTrackerProcessorDelegate {
    func displayFrame(_ frame: CVPixelBuffer?, withAffineTransform transform: CGAffineTransform, rects: [TrackedPolyRect]?) {
        DispatchQueue.main.async {
            if let frame = frame {
                let ciImage = CIImage(cvPixelBuffer: frame).transformed(by: transform)
                let uiImage = UIImage(ciImage: ciImage)
//                self.trackingView.image = uiImage
                print(frame)
            }
            
            
            
//            self.trackingView.polyRects = rects ?? (self.trackedObjectType == .object ? self.objectsToTrack : [])
//            self.trackingView.rubberbandingStart = CGPoint.zero
//            self.trackingView.rubberbandingVector = CGPoint.zero
//
//            self.trackingView.setNeedsDisplay()
        }
    }
    
    func displayFrameCounter(_ frame: Int) {
        
    }
}
