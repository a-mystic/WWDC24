//
//  File.swift
//  
//
//  Created by a mystic on 1/2/24.
//

import Foundation

struct PostureModel {
    private(set) var currentPostureMessage = ""
    private(set) var currentPostureMode = PostureMode.initial
    private(set) var isChanging = false
    private(set) var handPositions: [Hand] = []
    private(set) var footPositions: [Foot] = []
    
    struct Hand {
        var rightX: Float
        var rightY: Float
        var leftX: Float
        var leftY: Float
        var index: UInt64
    }
    
    struct Foot {
        var rightX: Float
        var rightY: Float
        var leftX: Float
        var leftY: Float
        var index: UInt64
    }
    
    enum PostureMode: String {
        case initial = "Initial"
        case rehearsal = "Rehearsal"
    }
    
    mutating func updatePostureMessage(_ posture: String) {
        currentPostureMessage = posture
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
}
