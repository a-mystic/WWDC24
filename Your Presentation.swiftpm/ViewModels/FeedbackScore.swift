//
//  File.swift
//
//
//  Created by a mystic on 2/4/24.
//

import Foundation

class FeedbackScore: ObservableObject {
    static let shared = FeedbackScore()
    
    @Published var score: Int = 0
}
