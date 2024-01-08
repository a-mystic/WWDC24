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
    private var index: UInt64 = 0
    private var face = FaceAnchor()
    private var faceManager = FaceManager.shared
    
    @Binding var expression: String
    
    init(expression: Binding<String>) {
        _expression = expression
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            print("ARTrackingSupported error")
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
                print("Video request error")
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
        self.expression = expression
        faceManager.setEmotion(expression)
    }
    
    
    
    func addLookAtPoint(x: Float, y: Float) {
        faceManager.addLookAtPoint(LookAtPoint(id: index, x: x, y: y))
        index += 1
    }
    
    func addColor(_ color: Color) {
        faceManager.addColor(color)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {   // Error prevention code when running ARView twice.
        if let arError = error as? ARError {
            switch arError.errorCode {
            case 102: setUp()
            default: setUp()
            }
        }
    }
}

struct FaceRecognitionViewRefer: UIViewControllerRepresentable { 
    @Binding var expression: String

    func makeUIViewController(context: Context) -> FaceRecognitionViewController {
        return FaceRecognitionViewController(expression: $expression)
    }
    
    func updateUIViewController(_ uiViewController: FaceRecognitionViewController, context: Context) { }
}

struct FaceRecognitionView: View {  
    @State private var expression = ""
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                FaceRecognitionViewRefer(expression: $expression)
                currentExpression
            }
        }
    }
    
    private var currentExpression: some View {
        VStack {
            Text(expression)
                .font(.largeTitle)
                .frame(alignment: .bottom)
            Spacer().frame(height: 100)
        }
    }
}

