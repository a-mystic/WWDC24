//
//  UtilitieViews.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

enum PlayStatus {
    case notPlay
    case play
    case finish
}

struct PlayButton: View {
    @State private var buttonState = PlayButtonState.start
    @EnvironmentObject var pageManager: PageManager
    
    var startAction: () -> Void
    var stopAction: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                switch buttonState {
                case .start: 
                    startAction()
                    buttonState = .stop
                case .stop: 
                    stopAction()
                    buttonState = .next
                case .next: 
                    pageManager.addPage()
                }
            }
        } label: {
            HStack {
                Image(systemName: buttonState.rawValue)
                Text(buttonState.description)
            }
            .padding()
            .font(.title2)
            .foregroundStyle(.black)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private enum PlayButtonState: String {
        case start = "play.fill"
        case stop = "stop.fill"
        case next = "arrow.right"
        var description: String {
            switch self {
            case .start:
                return "Play"
            case .stop:
                return "Stop"
            case .next:
                return "Next page"
            }
        }
    }
}

extension Array where Element == Float {
    private func mean() -> Float {
        return self.reduce(0, +) / Float(self.count)
    }
    
    func coefficientOfVariation() -> Float {
        let variance = self.map { pow($0 - self.mean(), 2) }.reduce(0, +) / Float(self.count)
        return sqrtf(variance) / self.mean()
    }
}

