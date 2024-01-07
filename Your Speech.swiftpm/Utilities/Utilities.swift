//
//  UtilitieViews.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI
import CoreGraphics // for cos.

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
            .foregroundStyle(.black)
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

struct Pie: Shape {
    var startAngle: Angle = Angle.zero
    var endAngle: Angle
    var clockwise = true
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.radians, endAngle.radians) }
        set {
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let startAngle = startAngle - .degrees(90)
        let endAngle = endAngle - .degrees(90)
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + radius * cos(startAngle.radians),
            y: center.y + radius * sin(startAngle.radians)
        )
        
        var p = Path()
        p.move(to: center)
        p.addLine(to: start)
        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: !clockwise
        )
        p.addLine(to: center)
        return p
    }
}
