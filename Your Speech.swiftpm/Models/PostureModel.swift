//
//  File.swift
//  
//
//  Created by a mystic on 1/2/24.
//

import Foundation

struct PostureModel {
    private(set) var currentPostureMessage = ""
    private(set) var currentPostureMode = PostureMode.ready
    private(set) var isChanging = false
    private(set) var handPositions: [Hand] = []
    private(set) var footPositions: [Foot] = []
    private(set) var notGoodPoint: Int = 0
    private(set) var goodPoint: Int = 0
    private(set) var recognizedPosture: [BadPostures:Int] = [
        .rightHand : 0,
        .leftHand : 0,
        .footDistance : 0,
        .isCrossLeg : 0
    ]
    
    
    struct Hand: Identifiable {
        var id: Int
        var rightX: Float
        var rightY: Float
        var leftX: Float
        var leftY: Float
    }
    
    struct Foot: Identifiable {
        var id: Int
        var rightX: Float
        var rightY: Float
        var leftX: Float
        var leftY: Float
    }
    
    enum PostureMode: String {
        case ready = "Ready"
        case rehearsal = "Rehearsal"
    }
    
    mutating func updatePostureMessage(_ posture: String) {
        if !isChanging {
            currentPostureMessage = posture
        }
    }
    
    mutating func toggleIsChanging() {
        isChanging = true
    }
    
    mutating func changeModeToRehearsal() {
        currentPostureMode = .rehearsal
    }
    
    mutating func addHandPosition(_ position: Hand) {
        handPositions.append(position)
    }
    
    mutating func addFootPosition(_ position: PostureModel.Foot) {
        footPositions.append(position)
    }
    
    mutating func notGood() {
        notGoodPoint += 1
    }
    
    mutating func good() {
        goodPoint += 1
    }
    
    mutating func updatePosture(_ posture: BadPostures) {
        if recognizedPosture.keys.contains(posture) {
            recognizedPosture[posture]! += 1
        }
    }
    
    enum BadPostures: String {
        case footDistance = "footDistance"
        case rightHand = "rightHandPosition"
        case leftHand = "leftHandPosition"
        case isCrossLeg = "CrossLeg"
    }
}
