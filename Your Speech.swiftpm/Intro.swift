//
//  Intro.swift
//  Your Speech
//
//  Created by a mystic on 11/28/23.
//

import SwiftUI

struct Intro: View {
    @EnvironmentObject var pageManager: PageManager
    
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 20) {
                Spacer()
                text
                next
                Spacer()
                tap
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
        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
    }
    
    @State private var currentTextIndex = 0
    @State private var isAnimation = true
    
    private var text: some View {
        Text(TextConstants.introTexts[currentTextIndex])
            .font(.largeTitle)
            .fontWeight(.black)
            .opacity(isAnimation ? 1 : 0)
    }
    
    @State private var needTap = false
    
    private var tap: some View {
        Text("Tap to start")
            .foregroundStyle(.white.opacity(0.8))
            .font(.largeTitle)
            .opacity(needTap ? 1 : 0)
            .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: needTap)
            .opacity(needTap ? 1 : 0)
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            isAnimation = false
            withAnimation(.linear(duration: 4)) {
                isAnimation = true
            }
            currentTextIndex += 1
            if currentTextIndex == TextConstants.introTexts.count - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        showButton = true
                    }
                }
                timer.invalidate()
            }
        }
    }
    
    @State private var showButton = false
    
    @ViewBuilder
    private var next: some View {
        if currentTextIndex == TextConstants.introTexts.count - 1 {
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
            .opacity(showButton ? 1 : 0)
        }
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
}
