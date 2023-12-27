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

final class FaceRecognitionViewController: UIViewController {
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
    
    private var videoManager = VideoManager()
    private var face = FaceAnchor()
        
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

extension FaceRecognitionViewController: ARSessionDelegate, FaceAnchorDelegate {
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
    
//    func session(_ session: ARSession, didFailWithError error: Error) {   // 영상 두번 실행할때 대비해서 오류 방지 코드
//        if let arError = error as? ARError {
//            switch arError.errorCode {
//            case 102: setUp()
//            default: setUp()
//            }
//        }
//    }
}

struct FaceRecognitionViewRefer: UIViewControllerRepresentable {
    @EnvironmentObject var faceManager: FaceManager
    
    @Binding var expression: String
    @Binding var expressionsOfRecognized: Set<String>

    func makeUIViewController(context: Context) -> FaceRecognitionViewController {
        return FaceRecognitionViewController(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized) { emotion in
            faceManager.setEmotion(emotion)
        }
    }
    
    func updateUIViewController(_ uiViewController: FaceRecognitionViewController, context: Context) { }
}

struct FaceRecognitionView: View {
    @State private var expression = ""
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                FaceRecognitionViewRefer(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized)
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
