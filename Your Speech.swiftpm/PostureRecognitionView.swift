//
//  PostureRecognitionView.swift
//  Your Speech
//
//  Created by a mystic on 12/30/23.
//
// The magic numbers used in the code were obtained through numerous tests.

import SwiftUI
import ARKit
import RealityKit
import Charts

final class PostureRecognitionViewController: UIViewController {
    private var arView = ARView(frame: .zero)
    private var index: UInt64 = 0
    private let footDistanceSmallRatio: Float = 1.45
    private let footDistanceLargeRatio: Float = 2.25
    
    private var postureManager = PostureManager.shared
    
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
    
    private var anchorEntity = AnchorEntity()
    private var sphere = ModelEntity()
    
    private func setUp() {
        let configuration = ARBodyTrackingConfiguration()
        arView.frame = view.frame
        arView.session.run(configuration)
        arView.session.delegate = self
        self.view.addSubview(self.arView)
        setSphere()
        arView.scene.addAnchor(anchorEntity)
    }
    
    private func setSphere() {
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: .red, roughness: 0, isMetallic: true)
        sphere = ModelEntity(mesh: sphereMesh, materials: [material])
        anchorEntity.addChild(sphere)
    }
}

extension PostureRecognitionViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                recognizePosture(bodyAnchor)
            }
        }
    }
    
    private func moveSphere(_ location: simd_float4) {
        anchorEntity.position = simd_float3(x: 0, y: 0, z: 0)
        sphere.position = simd_make_float3(location)
    }
    
    private func recognizePosture(_ bodyAnchor: ARBodyAnchor) {
        if let rightHandPos = bodyAnchor.skeleton.modelTransform(for: .rightHand)?.columns.3,
           let leftHandPos = bodyAnchor.skeleton.modelTransform(for: .leftHand)?.columns.3,
           let rightShoulderPos = bodyAnchor.skeleton.modelTransform(for: .rightShoulder)?.columns.3,
           let leftShoulderPos = bodyAnchor.skeleton.modelTransform(for: .leftShoulder)?.columns.3,
           let rightFootPos = bodyAnchor.skeleton.modelTransform(for: .rightFoot)?.columns.3,
           let leftFootPos = bodyAnchor.skeleton.modelTransform(for: .leftFoot)?.columns.3 
        {
            let shoulderDistance = abs(leftShoulderPos.x - rightShoulderPos.x)
            let footDistance = leftFootPos.x - rightFootPos.x
            let isCrossLeg = footDistance < 0
            let shoulderHeight = (leftShoulderPos.y + rightShoulderPos.y) / 2
            let rootPosition = bodyAnchor.transform.columns.3
            
            var readyCondition: Bool {
                rightHandPos.y < shoulderHeight * 0.95 &&
                leftHandPos.y < shoulderHeight * 0.95 &&
                footDistance > shoulderDistance * footDistanceSmallRatio && footDistance < shoulderDistance * footDistanceLargeRatio &&
                !isCrossLeg
            }
            
            // MARK: - Posture ready func
            if postureManager.currentPostureMode == .ready {
                if readyCondition {
                    arView.scene.removeAnchor(anchorEntity)
                    postureManager.updatePostureMessage("Initial Okay chagne mode after 5 second.")
                    postureManager.toggleIsChanging()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        self.postureManager.changeModeToRehearsal()
                    }
                } else if footDistance < shoulderDistance * footDistanceSmallRatio || footDistance > shoulderDistance * footDistanceLargeRatio {
                    if isCrossLeg {
                        postureManager.updatePostureMessage("Uncross your legs and Keep the space between your legs about shoulder width.")
                    } else {
                        postureManager.updatePostureMessage("Keep the space between your legs about shoulder width.")
                    }
                    moveSphere(rootPosition + rightFootPos)
                } else if rightHandPos.y > shoulderHeight * 0.95 {
                    postureManager.updatePostureMessage("Down your right Hand")
                    moveSphere(rootPosition + rightHandPos)
                } else if leftHandPos.y > shoulderHeight * 0.95 {
                    postureManager.updatePostureMessage("Down your left hand")
                    moveSphere(rootPosition + leftHandPos)
                } else if isCrossLeg {
                    postureManager.updatePostureMessage("Uncross your legs.")
                    moveSphere(rootPosition + rightFootPos)
                }
            }
            
            // MARK: - Posture rehearsal func
            if postureManager.currentPostureMode == .rehearsal {
             postureManager.addHandPosition(PostureModel.Hand(id: index, rightX: rightHandPos.x, rightY: rightHandPos.y, leftX: leftHandPos.x, leftY: leftHandPos.y))
             postureManager.addFootPosition(PostureModel.Foot(id: index, rightX: rightFootPos.x, rightY: rightFootPos.y, leftX: leftFootPos.x, leftY: leftFootPos.y))
             index += 1
             
             if rightHandPos.y > shoulderHeight * 0.95 ||
                leftHandPos.y > shoulderHeight * 0.95 ||
                isCrossLeg ||
                footDistance < shoulderDistance * footDistanceSmallRatio || footDistance > shoulderDistance * footDistanceLargeRatio {
                 postureManager.updatePostureMessage("Not good")
             } else {
                 postureManager.updatePostureMessage("Good")
             }
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
