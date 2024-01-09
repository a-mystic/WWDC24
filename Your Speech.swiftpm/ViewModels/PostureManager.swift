//
//  File.swift
//  
//
//  Created by a mystic on 12/30/23.
//

import Foundation

class PostureManager: ObservableObject {
    static let shared = PostureManager()
    
    @Published private(set) var model = PostureModel()
    
    var currentPosture: String {
        model.currentPostureMessage
    }
    
    var currentPostureMode: PostureModel.PostureMode {
        model.currentPostureMode
    }
    
    var handPositions: [PostureModel.Hand] {
        model.handPositions
    }
    
    var footPositions: [PostureModel.Foot] {
        model.footPositions
    }
    
    var isChanging: Bool {
        model.isChanging
    }
    
    var goodPoint: Int {
        model.goodPoint
    }
    
    var notGoodPoint: Int {
        model.notGoodPoint
    }
    
    func toggleIsChanging() {
        model.toggleIsChanging()
    }
    
    func updatePostureMessage(_ posture: String) {
        model.updatePostureMessage(posture)
    }
    
    func changeModeToRehearsal() {
        model.changeModeToRehearsal()
    }
    
    func addHandPosition(_ position: PostureModel.Hand) {
        model.addHandPosition(position)
    }
    
    func addFootPosition(_ position: PostureModel.Foot) {
        model.addFootPosition(position)
    }
    
    func notGood() {
        model.notGood()
    }
    
    func good() {
        model.good()
    }
}
