//
//  SwiftUIView.swift
//
//
//  Created by a mystic on 12/27/23.
//

import SwiftUI
import ARKit
import RealityKit
import Charts

final class FaceRecognitionViewController: UIViewController {
    private var arView = ARView(frame: .zero)
    private var index: Int = 0
    private var face = FaceAnchor()
    private var faceManager = FaceManager.shared
    
    deinit {
        self.arView.session.pause()
        self.arView.removeFromSuperview()
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        if ARFaceTrackingConfiguration.isSupported {
            requestPermission()
        } else {
            faceManager.faceErrorStatus = .ARTrackingSupportedError
            faceManager.showfaceError = true
        }
        self.view.addSubview(arView)
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] access in
            if access {
                DispatchQueue.main.async {
                    self?.setUp()
                }
            } else {
                self?.faceManager.faceErrorStatus = .videoRequestError
                self?.faceManager.showfaceError = true
            }
        }
    }
    
    private func setUp() {
        let configuration = ARFaceTrackingConfiguration()
        arView.frame = view.frame
        arView.session.run(configuration)
        arView.session.delegate = self
        face.delegate = self
        self.view.addSubview(self.arView)
    }
}

extension FaceRecognitionViewController: ARSessionDelegate, FaceAnchorDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                face.analyze(faceAnchor: faceAnchor)
            }
        }
    }
    
    func updateExpression(_ expression: String) {
        faceManager.setEmotion(expression)
    }
    
    
    
    func addLookAtPoint(x: Float, y: Float) {
        faceManager.addLookAtPoint(LookAtPoint(id: index, x: x, y: y))
        index += 1
    }
    
    func addColor(_ color: Color) {
        faceManager.addColor(color)
    }
    
    func updateBlink(_ isBlink: Bool) {
        faceManager.addBlink(isBlink)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {   // Error prevention when running ARView twice.
        if let arError = error as? ARError {
            switch arError.errorCode {
            case 102: setUp()
            default: setUp()
            }
        }
    }
}

struct FaceRecognitionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FaceRecognitionViewController {
        return FaceRecognitionViewController()
    }
    
    func updateUIViewController(_ uiViewController: FaceRecognitionViewController, context: Context) { }
}

