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
    
    @Binding var value: String
    
    init(
        value: Binding<String>
    ) {
        _value = value
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
               let rightHand = bodyAnchor.skeleton.modelTransform(for: .rightHand),
               let leftHand = bodyAnchor.skeleton.modelTransform(for: .leftHand),
               let rightShoulder = bodyAnchor.skeleton.modelTransform(for: .rightShoulder),
               let leftShoulder = bodyAnchor.skeleton.modelTransform(for: .leftShoulder),
               let rightFoot = bodyAnchor.skeleton.modelTransform(for: .rightFoot),
               let leftFoot = bodyAnchor.skeleton.modelTransform(for: .leftFoot) {
                let rightHandPosition = abs(rightHand[0][0]) * 100
                let leftHandPosition = abs(leftHand[0][0]) * 100
                let shoulderDistanceX = (abs(rightShoulder[0][0]) - abs(leftShoulder[0][0])) * 100
                let shoulderDistanceY = (abs(rightShoulder[1][1]) - abs(leftShoulder[1][1])) * 100
                let footDistanceX = (abs(rightFoot[0][0]) - abs(leftFoot[0][0])) * 100
                let footDistanceY = (abs(rightFoot[1][1]) - abs(leftFoot[1][1])) * 100
                
                
                let rightHandPosX = rightHand[0][0] * 100
                let rightHandPosY = rightHand[1][1] * 100
                let shoulderRightposX = rightShoulder[0][0] * 100
                let shoulderleftposX = leftShoulder[0][0] * 100
                let shoulderRightposY = rightShoulder[1][1] * 100
                let shoulderleftPosY = leftShoulder[1][1] * 100
                let rightFootposX = rightFoot[0][0] * 100
                let leftFootposX = leftFoot[0][0] * 100
                let rightFootposY = rightFoot[1][1] * 100
                let leftFootposY = leftFoot[1][1] * 100
                
                value = """
                rightHandPosX: \(rightHandPosX)
                rightHandPosY: \(rightHandPosY)

                """
                
//            rightFootPosX: \(rightFootposX)
//            leftFootPosX: \(leftFootposX)
//            rightFootPosY: \(rightFootposY)
//            leftFootPosY: \(leftFootposY)
//            
//            rightShoulderposX: \(shoulderRightposX)
//            leftShoulderposX: \(shoulderleftposX)
//            rightShoulderposY: \(shoulderRightposY)
//            leftShoulderposY: \(shoulderleftPosY)
//
                //                 rightHand: \(rightHandPosition)\n leftHand: \(leftHandPosition)\nShoulderDistanceX: \(shoulderDistanceX)\n ShoulderDistanceY: \(shoulderDistanceY)\nfootDistanceX: \(footDistanceX)\n footDistanceY: \(footDistanceY)\nrightShoulderposX: \(shoulderRightpos)\nleftShoulderpos: \(shoulderleftpos)
                }
            }
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

struct PostureRecognitionViewRefer: UIViewControllerRepresentable {    // replace posturerecognitionView later..
    @Binding var value: String

    func makeUIViewController(context: Context) -> PostureRecognitionViewController {
        return PostureRecognitionViewController(value: $value)
    }
    
    func updateUIViewController(_ uiViewController: PostureRecognitionViewController, context: Context) { }
}
