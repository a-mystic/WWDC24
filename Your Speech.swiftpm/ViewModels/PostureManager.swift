//
//  File.swift
//  
//
//  Created by a mystic on 12/30/23.
//

import Foundation

class PostureManager: ObservableObject {
    @Published private(set) var currentPosture = ""
    
    func updatePosture(_ posture: String) {
        currentPosture = posture
    }
}
