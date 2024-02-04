//
//  Finish.swift
//  Your Speech
//
//  Created by a mystic on 12/23/23.
//

import SwiftUI

struct Finish: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                message(in: geometry.size)
            }
            .onAppear {
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
                .frame(width: size.width * 0.6, height: size.height * 0.6)
                .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    Finish()
        .preferredColorScheme(.dark)
}
