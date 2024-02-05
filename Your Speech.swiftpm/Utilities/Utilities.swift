//
//  UtilitieViews.swift
//  Your Presentation
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
            .padding()
            .font(.headline)
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
            return abs(sqrtf(variance) / self.mean())
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

extension Character {
    var isEmoji: Bool {
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

extension String {
    var isContainEmoji: Bool {
        for char in self {
            if char.isEmoji {
                return true
            }
        }
        return false
    }
}

struct EmotionColor {
    static let idle = Color.white
    static let smile = Color.teal
    static let verySmile = Color.mint
    static let angry = Color.orange
    static let veryAngry = Color.red
    static let tongue = Color.purple
}

struct SpecialBrownBackground: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white.opacity(0.14))
                .background(.brown.gradient, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
