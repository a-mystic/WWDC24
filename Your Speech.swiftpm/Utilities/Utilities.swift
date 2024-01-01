//
//  UtilitieViews.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct PlayButton: View {
    @EnvironmentObject var pageManager: PageManager
    
    @Binding var playStatus: PlayStatus
    var startAction: () -> Void
    var stopAction: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                switch playStatus {
                case .notPlay:
                    startAction()
                case .play:
                    stopAction()
                case .finish:
                    pageManager.addPage()
                }
            }
        } label: {
            HStack {
                Image(systemName: playStatus.rawValue)
                Text(playStatus.description)
            }
            .padding()
            .font(.title2)
        }
        .buttonStyle(.borderedProminent)
    }
    
    enum PlayStatus: String {
        case notPlay = "play.fill"
        case play = "stop.fill"
        case finish = "arrow.right"
        var description: String {
            switch self {
            case .notPlay:
                return "Start"
            case .play:
                return "Finish"
            case .finish:
                return "Next"
            }
        }
    }
}

extension Array where Element == Float {
    private func mean() -> Float {
        return self.reduce(0, +) / Float(self.count)
    }
    
    func coefficientOfVariation() -> Float? {
        if self.isEmpty {
            return nil
        } else {
            let variance = self.map { pow($0 - self.mean(), 2) }.reduce(0, +) / Float(self.count)
            return sqrtf(variance) / self.mean()
        }
    }
}

struct Shake: AnimatableModifier {
    var shakes: CGFloat = 0
    
    var animatableData: CGFloat {
        get {
            shakes
        } set {
            shakes = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * 5)
    }
}

extension View {
    func shake(with shakes: CGFloat) -> some View {
        self.modifier(Shake(shakes: shakes))
    }
}

