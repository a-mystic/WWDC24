//
//  Intro.swift
//  Your Speech
//
//  Created by a mystic on 11/28/23.
//

import SwiftUI

struct Intro: View {
    @EnvironmentObject var pageManager: PageManager
    
    private let texts = [
        "I know you have great idea.",
        "And I ensure your idea can change world.",
        "And third.",
        "And forth."
    ]
    
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 20) {
                text
                tap
                next
            }
        }
        .navigationTitle("Intro")
        .onAppear {
            withAnimation {
                needTap = true
            }
        }
        .onTapGesture {
            if needTap {
                startAnimation()
                needTap = false
            }
        }
        .opacity(isAnimation ? 1 : 0)
        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
    }
    
    @State private var currentText = 0
    @State private var isAnimation = true
    
    private var text: some View {
        Text(texts[currentText])
            .font(.largeTitle)
            .fontWeight(.black)
    }
    
    @State private var needTap = false
    
    private var tap: some View {
        Text("Tap")
            .foregroundStyle(.gray)
            .font(.title)
            .scaleEffect(needTap ? 1 : 0)
            .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: needTap)
            .opacity(needTap ? 1 : 0)
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            isAnimation = false
            withAnimation(.linear(duration: 3)) {
                isAnimation = true
            }
            currentText += 1
            if currentText == texts.count - 1 {
                timer.invalidate()
            }
        }
    }
    
    @ViewBuilder
    private var next: some View {
        if currentText == texts.count - 1 {
            Button {
                withAnimation {
                    pageManager.addPage()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("Next page")
                }
                .padding()
                .font(.title)
                .foregroundStyle(.black)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
}
