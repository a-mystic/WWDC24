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
    
    let postureManager = PostureManager.shared
    
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
                let footDistance = leftFootPos.x - rightFootPos.x
                
                postureManager.updatePosture("foot distance: \(footDistance)")
//                if postureManager.currentPostureMode == .initial {
//                    if rightHandPosition < rightShoulderPos.y * 0.85 &&
//                        leftHandPosition < leftShoulderPos.y * 0.85 &&
//                        footDistance > shoulderDistance * 1.7 &&
//                        footDistance < shoulderDistance * 2.2 {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            self.postureManager.updatePosture("Initial Okay")
//                            self.postureManager.changeMode(.rehearsal)
//                        }
//                    } else {
//                        postureManager.updatePosture("spread your legs shoulder width apart")
//                    }
//                } else if postureManager.currentPostureMode == .rehearsal {
//                    if rightHandPosition > rightShoulderPos.y * 0.85 || leftHandPosition > leftShoulderPos.y * 0.85 {
//                        postureManager.updatePosture("Over shoulder")
//                    } else {
//                        postureManager.updatePosture("Not")
//                    }
//                }
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
    func makeUIViewController(context: Context) -> PostureRecognitionViewController {
        return PostureRecognitionViewController()
    }
    
    func updateUIViewController(_ uiViewController: PostureRecognitionViewController, context: Context) { }
}
