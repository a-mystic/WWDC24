//
//  File.swift
//  
//
//  Created by a mystic on 12/30/23.
//

import Foundation

class PostureManager: ObservableObject {
    static let shared = PostureManager()
    
    @Published private(set) var currentPosture = ""
    @Published private(set) var currentPostureMode = PostureMode.initial
    @Published var isChanging = false
    
    enum PostureMode: String {
        case initial = "Initial"
        case rehearsal = "Rehearsal"
    }
    
    func updatePosture(_ posture: String) {
        currentPosture = posture
    }
    
    func changeModeToRehearsal() {
        currentPostureMode = .rehearsal
    }
}
