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
    private var index = 0
    private var face = FaceAnchor()
    
    @Binding var expression: String
    @Binding var expressionsOfRecognized: Set<String>
    @Binding var position: [LookAtPosition]
    
    var setEmotion: (String) -> Void
    
    init(
        expression: Binding<String>,
        expressionsOfRecognized: Binding<Set<String>>,
        position: Binding<Array<LookAtPosition>>,
        setEmotion: @escaping (String) -> Void
    ) {
        _expression = expression
        _expressionsOfRecognized = expressionsOfRecognized
        _position = position
        self.setEmotion = setEmotion
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
    
    func update(expression: String) {
        self.expression = expression
        self.expressionsOfRecognized.insert(expression)
        setEmotion(expression)
    }
    
    func updateLookat(x: Float, y: Float) {
        position.append(LookAtPosition(index: index, x: x, y: y))
        index += 1
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
    @Binding var position: [LookAtPosition]

    func makeUIViewController(context: Context) -> FaceRecognitionViewController {
        return FaceRecognitionViewController(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized, position: $position) { emotion in
            faceManager.setEmotion(emotion)
        }
    }
    
    func updateUIViewController(_ uiViewController: FaceRecognitionViewController, context: Context) { }
}

struct FaceRecognitionView: View {
    @State private var expression = ""
    @Binding var position: [LookAtPosition]
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                FaceRecognitionViewRefer(expression: $expression, expressionsOfRecognized: $expressionsOfRecognized, position: $position)
                currentExpression
            }
        }
    }
    
    @State private var expressionsOfRecognized = Set<String>()
    
    private var currentExpression: some View {
        VStack {
            Text(expression)
                .font(.largeTitle)
                .frame(alignment: .bottom)
            Spacer().frame(height: 100)
        }
    }
}

