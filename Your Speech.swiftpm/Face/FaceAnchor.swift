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
}

final class FaceAnchor: NSObject {
    weak var delegate: FaceAnchorDelegate?
    
    private var expression = ""
    private var faceColor = Color.white
    
    func analyze(faceAnchor: ARFaceAnchor) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.addLookAtPoint(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y)
        }
        mouth(faceAnchor)
        eyebrow(faceAnchor)
        tongue(faceAnchor)
        mouthAndeyes(faceAnchor)
    }
    
    private func mouth(_ faceAnchor: ARFaceAnchor) {
        let mouthSmileLeft = faceAnchor.blendShapes[.mouthSmileLeft] as? CGFloat ?? 0
        let mouthSmileRight = faceAnchor.blendShapes[.mouthSmileRight] as? CGFloat ?? 0
        let smile = (mouthSmileLeft + mouthSmileRight) / 2
        DispatchQueue.main.async { [weak self] in
            self?.isSmile(value: smile)
        }
    }
    
    private func eyebrow(_ faceAnchor: ARFaceAnchor) {
        let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? CGFloat ?? 0
        let browDownRight = faceAnchor.blendShapes[.browDownRight] as? CGFloat ?? 0
        let fret = (browDownLeft + browDownRight) / 2
        DispatchQueue.main.async { [weak self] in
            self?.isFret(value: fret)
        }
    }
    
    private func tongue(_ faceAnchor: ARFaceAnchor) {
        let tongueOut = faceAnchor.blendShapes[.tongueOut] as? CGFloat ?? 0
            DispatchQueue.main.async { [weak self] in
                self?.isTongueOut(value: tongueOut)
        }
    }
    
    private func mouthAndeyes(_ faceAnchor: ARFaceAnchor) {
        let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? CGFloat ?? 0
        let jawOpen = faceAnchor.blendShapes[.jawOpen] as? CGFloat ?? 0
        let eyeWideLeft = faceAnchor.blendShapes[.eyeWideLeft] as? CGFloat ?? 0
        let eyeWideRight = faceAnchor.blendShapes[.eyeWideRight] as? CGFloat ?? 0
        let openValue = (mouthFunnel + jawOpen + eyeWideLeft + eyeWideRight) / 4
        DispatchQueue.main.async { [weak self] in
            self?.isMouthOpen(value: openValue)
        }
    }

    
    private func isSmile(value: CGFloat) {
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
    
    private func isFret(value: CGFloat) {
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
    
    private func isTongueOut(value:  CGFloat) {
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
    
    private func isMouthOpen(value: CGFloat) {
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
