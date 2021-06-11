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
import Vision

final class CameraLayerViewController: UIViewController {
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var sampleOutputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private var detectionOverlay = CALayer()
    var bufferSize: CGSize = .zero
    
    let dataOutputQueue = DispatchQueue(
    label: "video data queue",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayers()
        updateLayerGeometry()
        
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
        
      do {
          try  camera.lockForConfiguration()
          let dimensions = CMVideoFormatDescriptionGetDimensions((camera.activeFormat.formatDescription))
          bufferSize.width = CGFloat(dimensions.width)
          bufferSize.height = CGFloat(dimensions.height)
          camera.unlockForConfiguration()
      } catch {
          print(error)
      }
    }
    
    func setupLayers() {
        detectionOverlay.borderWidth = 2.0
        detectionOverlay.borderColor = UIColor.orange.cgColor
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.layer.addSublayer(detectionOverlay)
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, text: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: text)
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func updateLayerGeometry() {
        let bounds = view.bounds
        var scale: CGFloat

        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width

        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)

        CATransaction.commit()
    }
}

// reconfigure this so its just a rectangle detector for now



extension CameraLayerViewController: VisionTrackerProcessorDelegate {
    func drawVisionRequestResults(_ rectangleObservation: VNRectangleObservation?, text: String?) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        guard let rectangleObservation = rectangleObservation, let text = text else {
            detectionOverlay.sublayers?.removeAll()
            updateLayerGeometry()
            CATransaction.commit()
            return
        }
        
        let objectBounds = VNImageRectForNormalizedRect(rectangleObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
        let shapeLayer = createRoundedRectLayerWithBounds(objectBounds)
        let textlayer = createTextSubLayerInBounds(objectBounds, text: text)
        shapeLayer.addSublayer(textlayer)
        detectionOverlay.addSublayer(shapeLayer)
        updateLayerGeometry()
        CATransaction.commit()
    }
    
    func displayFrameCounter(_ frame: Int) {
        
    }
}
