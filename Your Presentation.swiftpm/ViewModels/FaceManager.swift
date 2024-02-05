//
//  File.swift
//
//
//  Created by a mystic on 12/27/23.
//

import SwiftUI

class FaceManager: ObservableObject {
    static let shared = FaceManager()
    
    @Published private(set) var faceEmotions: [String:Int] = [
        "😁" : 0,
        "🙂" : 0,
        "😡" : 0,
        "😠" : 0,
        "😛" : 0,
        "😮" : 0,
        "😐" : 0
    ]
    
    @Published private(set) var lookAtPoint: [LookAtPoint] = []
    @Published private(set) var faceColors: Set<Color> = [.white]
    @Published var faceErrorStatus = FaceError.notError
    @Published var showfaceError = false
    @Published var blink: Float = 0
    @Published var notBlink: Float = 0
    
    
    var faceColor: LinearGradient {
        LinearGradient(colors: Array(faceColors), startPoint: .bottomLeading, endPoint: .topTrailing)
    }
    
    func addColor(_ color: Color) {
        if !faceColors.contains(color) {
            faceColors.insert(color)
        }
    }
    
    func setEmotion(_ emotion: String) {
        if faceEmotions.keys.contains(emotion) {
            faceEmotions[emotion]! += 1
        }
    }
    
    func addLookAtPoint(_ point: LookAtPoint) {
        lookAtPoint.append(point)
    }
    
    func addBlink(_ isBlink: Bool) {
        if isBlink {
            blink += 1
        } else {
            notBlink += 1
        }
    }
    
    enum FaceError: Error {
        case notError
        case ARTrackingSupportedError
        case videoRequestError
        
        var errorMessage: String {
            switch self {
            case .ARTrackingSupportedError:
                return "AR Tracking Supported Error occured."
            case .videoRequestError:
                return "Video Request Error occured."
            default:
                return "Something can't recognized error occured"
            }
        }
    }
}
