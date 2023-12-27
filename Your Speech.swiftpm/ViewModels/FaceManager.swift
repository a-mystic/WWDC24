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
    
    func setEmotion(_ emotion: String) {
        if faceEmotions.keys.contains(emotion) {
            faceEmotions[emotion]! += 1
        }
    }
}
