//
//  Finish.swift
//  Your Presentation
//
//  Created by a mystic on 12/23/23.
//

import SwiftUI

struct Finish: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                VStack(spacing: 30) {
                    Text("Your final score: \(finalScore)")
                        .font(.largeTitle)
                        .bold()
                    message(in: geometry.size)
                }
            }
            .onAppear {
                evaluate()
                withAnimation(.easeInOut(duration: 1.5)) {
                    showMessage = true
                }
            }
        }
    }
    
    @State private var showMessage = false
    
    @ViewBuilder
    private func message(in size: CGSize) -> some View {
        if showMessage {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white.gradient)
                .overlay {
                    VStack(spacing: 40) {
                        Text("Thank you")
                            .font(.largeTitle)
                            .bold()
                        Text(TextConstants.finishText)
                            .font(.title)
                            .fontWeight(.light)
                    }
                    .foregroundStyle(.black)
                }
                .frame(width: size.width * 0.6, height: size.height * 0.5)
                .transition(.move(edge: .bottom))
        }
    }
    
    @StateObject private var feedbackScore = FeedbackScore.shared
    @State private var finalScore = ""
    
    private func evaluate() {
        switch feedbackScore.score {
        case 0...4:
            finalScore = "😀 Very Good"
        case 5...8:
            finalScore = "🙂 Good"
        default:
            finalScore = "😢 Not Good"
        }
    }
}

#Preview {
    Finish()
        .preferredColorScheme(.dark)
}
