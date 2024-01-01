//
//  PostureRecognitionView.swift
//  Your Speech
//
//  Created by a mystic on 12/30/23.
//

import SwiftUI
import ARKit
import RealityKit
import Charts

final class PostureRecognitionViewController: UIViewController {
    private var arView = ARView(frame: .zero)
    private var index = 0
    
    @Binding var postureMode: PostureManager.PostureMode
    var completion: (String) -> Void
    
    init(postureMode: Binding<PostureManager.PostureMode>, completion: @escaping (String) -> Void) {
        _postureMode = postureMode
        self.completion = completion
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
        let configuration = ARBodyTrackingConfiguration()
        arView.frame = view.frame
        arView.session.run(configuration)
        arView.session.delegate = self
        self.view.addSubview(self.arView)
    }
}

extension PostureRecognitionViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor,
               let rightHandPos = bodyAnchor.skeleton.modelTransform(for: .rightHand)?.columns.3,
               let leftHandPos = bodyAnchor.skeleton.modelTransform(for: .leftHand)?.columns.3,
               let rightShoulderPos = bodyAnchor.skeleton.modelTransform(for: .rightShoulder)?.columns.3,
               let leftShoulderPos = bodyAnchor.skeleton.modelTransform(for: .leftShoulder)?.columns.3,
               let rightFootPos = bodyAnchor.skeleton.modelTransform(for: .rightFoot)?.columns.3,
               let leftFootPos = bodyAnchor.skeleton.modelTransform(for: .leftFoot)?.columns.3 {
                let rightHandPosition = rightHandPos.y
                let leftHandPosition = leftHandPos.y
                let shoulderDistance = abs(leftShoulderPos.x - rightShoulderPos.x)
                let footDistance = abs(leftFootPos.x - rightFootPos.x)
                
                if postureMode == .initial {
                    if rightHandPosition < rightShoulderPos.y * 0.85 &&
                        leftHandPosition < leftShoulderPos.y * 0.85 &&
                        footDistance > shoulderDistance * 1.7 &&
                        footDistance < shoulderDistance * 2.2 {
                        completion("Initial Okay")
                        postureMode = .rehearsal
                    } else {
                        completion("spread your legs shoulder width apart")
                    }
                } else if postureMode == .rehearsal {
                    if rightHandPosition > rightShoulderPos.y * 0.85 || leftHandPosition > leftShoulderPos.y * 0.85 {
                        completion("Over shoulder")
                    } else {
                        completion("Not")
                    }
                }
                
//                value = """
//                rightHandPos = \(rightHandPosition)
//                rootPos = \(rootPos.y)
//                shoulderDistance = \(shoulderDistance)
//                footDistance = \(footDistance)
//                """
                }
            }
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

struct PostureRecognitionViewRefer: UIViewControllerRepresentable {
    @EnvironmentObject var postureManager: PostureManager
    
    func makeUIViewController(context: Context) -> PostureRecognitionViewController {
        return PostureRecognitionViewController(postureMode: $postureManager.currentPostureMode) { posture in
            postureManager.updatePosture(posture)
        }
    }
    
    func updateUIViewController(_ uiViewController: PostureRecognitionViewController, context: Context) { }
}
