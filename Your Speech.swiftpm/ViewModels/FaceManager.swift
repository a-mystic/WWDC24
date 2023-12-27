//
//  File.swift
//  
//
//  Created by a mystic on 12/27/23.
//

import SwiftUI

class FaceManager: ObservableObject {
    @Published private(set) var faceEmotions: [String:Int] = [
        "😁" : 0,
        "🙂" : 0,
        "😡" : 0,
        "😠" : 0,
        "😛" : 0,
        "😮" : 0
    ]
    @Published private(set) var isAnalyzing = false
    @Published var currentEmotion = "😐"
    
    func setEmotion(_ emotion: String) {
        if isAnalyzing {
            currentEmotion = emotion
            if faceEmotions.keys.contains(emotion) {
                faceEmotions[emotion]! += 1
            }
        }
    }
    
    func startAnalyzing() {
        isAnalyzing = true
    }
    
    func stopAnalyzing() {
        isAnalyzing = false
    }
}
