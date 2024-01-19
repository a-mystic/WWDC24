//
//  File.swift
//  
//
//  Created by a mystic on 12/27/23.
//

import ARKit
import SwiftUI

protocol FaceAnchorDelegate: AnyObject {
    func updateExpression(_ expression: String)
    func addLookAtPoint(x: Float, y: Float)
    func addColor(_ color: Color)
    func updateBlink(_ isBlink: Bool)
}

final class FaceAnchor: NSObject {
    weak var delegate: FaceAnchorDelegate?
    
    private var expression = ""
    private var faceColor = Color.white
    
    func analyze(faceAnchor: ARFaceAnchor) {
        eyesBlink(faceAnchor)
        eyebrow(faceAnchor)
        eyesLookAt(faceAnchor)
        mouth(faceAnchor)
        tongue(faceAnchor)
        mouthAndeyes(faceAnchor)
    }
    
    private func eyesBlink(_ faceAnchor: ARFaceAnchor) {
        if let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft] as? CGFloat,
           let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight] as? CGFloat {
            DispatchQueue.main.async { [weak self] in
                if eyeBlinkLeft > 0.94 && eyeBlinkRight > 0.94 {
                    self?.delegate?.updateBlink(true)
                } else {
                    self?.delegate?.updateBlink(false)
                }
            }
        }
    }
    
    private func eyebrow(_ faceAnchor: ARFaceAnchor) {
        if let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? CGFloat,
           let browDownRight = faceAnchor.blendShapes[.browDownRight] as? CGFloat {
            let value = (browDownLeft + browDownRight) / 2
            DispatchQueue.main.async { [weak self] in
                self?.isFret(value)
            }
        }
    }
    
    private func eyesLookAt(_ faceAnchor: ARFaceAnchor) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.addLookAtPoint(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
        }
    }
    
    private func mouth(_ faceAnchor: ARFaceAnchor) {
        if let mouthSmileLeft = faceAnchor.blendShapes[.mouthSmileLeft] as? CGFloat,
           let mouthSmileRight = faceAnchor.blendShapes[.mouthSmileRight] as? CGFloat {
            let value = (mouthSmileLeft + mouthSmileRight) / 2
            DispatchQueue.main.async { [weak self] in
                self?.isSmile(value)
            }
        }
    }
    
    private func tongue(_ faceAnchor: ARFaceAnchor) {
        if let value = faceAnchor.blendShapes[.tongueOut] as? CGFloat {
            DispatchQueue.main.async { [weak self] in
                self?.isTongueOut(value)
            }
        }
    }
    
    private func mouthAndeyes(_ faceAnchor: ARFaceAnchor) {
        if let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? CGFloat,
           let jawOpen = faceAnchor.blendShapes[.jawOpen] as? CGFloat,
           let eyeWideLeft = faceAnchor.blendShapes[.eyeWideLeft] as? CGFloat,
           let eyeWideRight = faceAnchor.blendShapes[.eyeWideRight] as? CGFloat {
            let value = (mouthFunnel + jawOpen + eyeWideLeft + eyeWideRight) / 4
            DispatchQueue.main.async { [weak self] in
                self?.isSurprise(value)
            }
        }
    }

    
    private func isSmile(_ value: CGFloat) {
        switch value {
        case 0.5..<1: 
            expression = "😁"
            faceColor = EmotionColor.verySmile
        case 0.2..<0.5:
            expression = "🙂"
            faceColor = EmotionColor.smile
        default:
            expression = "😐"
            faceColor = EmotionColor.idle
        }
        delegate?.updateExpression(expression)
        delegate?.addColor(faceColor)
    }
    
    private func isFret(_ value: CGFloat) {
        switch value {
        case 0.55..<1:
            expression = "😡"
            faceColor = EmotionColor.veryAngry
        case 0.35..<0.55:
            expression = "😠"
            faceColor = EmotionColor.angry
        default:
            return
        }
        delegate?.updateExpression(expression)
        delegate?.addColor(faceColor)
    }
    
    private func isTongueOut(_ value:  CGFloat) {
        switch value {
        case 0.1..<1: 
            expression = "😛"
            faceColor = EmotionColor.tongue
        default:
            return
        }
        delegate?.updateExpression(expression)
        delegate?.addColor(faceColor)
    }
    
    private func isSurprise(_ value: CGFloat) {
        switch value {
        case 0.2..<1: 
            expression = "😮"
            faceColor = EmotionColor.idle
        default:
            faceColor = EmotionColor.idle
            return
        }
        delegate?.updateExpression(expression)
        delegate?.addColor(faceColor)
    }
}
