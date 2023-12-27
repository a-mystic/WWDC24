//
//  SwiftUIView.swift
//  
//
//  Created by a mystic on 12/27/23.
//

import UIKit
import SwiftUI
import ARKit
import RealityKit

final class FacialController: UIViewController {
    private var arView = ARView(frame: .zero)
    
    @Binding var expression: String
    @Binding var expressionsOfRecognized: Set<String>
    
    var setEmotion: (String) -> Void
    
    init(
        expression: Binding<String>,
        expressionsOfRecognized: Binding<Set<String>>,
        setEmotion: @escaping (String) -> Void
    ) {
        _expression = expression
        _expressionsOfRecognized = expressionsOfRecognized
        self.setEmotion = setEmotion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.arView.session.pause()
        self.videoManager.stopVideoCapturing()
        self.arView.removeFromSuperview()
    }
    
    private var videoManager = Video()
    
    private var face = FaceAnchor()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        if isARTrackingSupported {
            requestPermission()
        } else {
            print("ARTrackingSupported error")
        }
        self.view.addSubview(arView)
    }
    
    private var isARTrackingSupported: Bool {
        ARFaceTrackingConfiguration.isSupported
    }
    
    private func requestPermission() {
        videoManager.requestPermission { [weak self] accessGranted in
            if accessGranted {
                DispatchQueue.main.async {
                    self?.setUp()
                }
            } else {
                print("videoManager request error")
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
        videoManager.startVideoCapturing()
        addCamera()
    }
    
    private func addCamera() {
        let videoLayer = videoManager.videoLayer
        videoLayer.frame = self.view.frame
        videoLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
    }
}

extension FacialController: ARSessionDelegate, FaceAnchorDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                face.analyze(faceAnchor: faceAnchor)
            }
        }
    }
    
    func update(expression: String) {
        self.expression = expression
        self.expressionsOfRecognized.insert(expression)
        setEmotion(expression)
    }
}

struct FacialViewRefer: UIViewControllerRepresentable {
    @EnvironmentObject var emotionManager: FaceManager
    
    @Binding var expression: String
    @Binding var expressionsOfRecognized: Set<String>

    func makeUIViewController(context: Context) -> FacialController {
        return FacialController(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized) { emotion in
            emotionManager.setEmotion(emotion)
        }
    }
    
    func updateUIViewController(_ uiViewController: FacialController, context: Context) { }
}

struct FacialView: View {
    @EnvironmentObject var emotionManager: FaceManager
    
    @State private var expression = ""
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                FacialViewRefer(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized)
                currentExpression
            }
        }
    }
    
    @State private var expressionsOfRecognized = Set<String>()
    
    var currentExpression: some View {
        VStack {
            Text(expression)
                .frame(alignment: .bottom)
            Spacer().frame(height: 20)
        }
    }
}

