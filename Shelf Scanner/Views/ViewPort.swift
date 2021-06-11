import Foundation
import SwiftUI
import Vision
import VisionKit
import AVKit

struct ViewPort: UIViewControllerRepresentable {
    
    let recognizedItemPublisher = RecognizedItemPublisher()
    let searchTerm: String
    
    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }
    
    typealias UIViewControllerType = VisionObjectRecognitionViewController
    
    func makeCoordinator() -> ViewCoordinator {
        ViewCoordinator(recognizedItemPublisher: recognizedItemPublisher, searchTerm: searchTerm)
    }
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ViewPort>
    ) -> VisionObjectRecognitionViewController {
        VisionObjectRecognitionViewController(searchTerm: searchTerm)
    }
    
    func updateUIViewController(
        _ uiViewController: VisionObjectRecognitionViewController,
        context: UIViewControllerRepresentableContext<ViewPort>
    ) {}
}
