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
    @Binding var recognizedText: String
    
    typealias UIViewControllerType = CameraLayerViewController
    
    func makeCoordinator() -> MyCoordinator {
        return MyCoordinator(recognizedText: $recognizedText)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewPort>) -> CameraLayerViewController {
        let vc = CameraLayerViewController()
        vc.sampleOutputDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CameraLayerViewController, context: UIViewControllerRepresentableContext<ViewPort>) { }
}

final class CameraLayerViewController: UIViewController {
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var sampleOutputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    let recognizedTextLabel = UILabel()
    
    let dataOutputQueue = DispatchQueue(
    label: "video data queue",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recognizedTextLabel.textColor = .white
        recognizedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recognizedTextLabel)
        
        NSLayoutConstraint.activate([
            recognizedTextLabel.topAnchor.constraint(equalTo: view.topAnchor),
            recognizedTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recognizedTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
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

class MyCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let textRecognizer: TextRecognizer
    
    init(recognizedText: Binding<String>) {
       textRecognizer = TextRecognizer(recognizedText: recognizedText)
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return
        }
        
        textRecognizer.recognizeText(fromBuffer: imageBuffer)
    }
}
