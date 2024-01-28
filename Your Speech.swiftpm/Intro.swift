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
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.02) {
                Spacer()
                currentText(in: geometry.size)
                letsGo
                Spacer()
                guideMessage
                Spacer()
                    .frame(height: geometry.size.height * 0.05)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
            .onTapGesture {
                next()
            }
        }
    }
    
    @State private var currentTextIndex = 0
    
    private func currentText(in size: CGSize) -> some View {
        VStack(spacing: size.height * 0.02) {
            Text(TextConstants.introEmojis[currentTextIndex])
                .font(.system(size: emojiSize(in: size)))
            Text(TextConstants.introTexts[currentTextIndex])
                .font(.largeTitle)
        }
        .multilineTextAlignment(.center)
        .fontWeight(.black)
        .padding()
    }
    
    private func emojiSize(in size: CGSize) -> CGFloat {
        return min(size.width * 0.07, size.height * 0.07)
    }
    
    @State private var showGuideMessage = true
    @State private var needStart = true
    @State private var hideGuideMessage = false
    
    private var guideMessageText: String {
        if needStart {
            return "Tap to start"
        } else {
            return "Tap to continue"
        }
    }
    
    @ViewBuilder
    private var guideMessage: some View {
        if !hideGuideMessage {
            Text(guideMessageText)
                .foregroundStyle(.white.opacity(0.8))
                .font(.largeTitle)
                .opacity(showGuideMessage ? 1 : 0)
                .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: showGuideMessage)
                .onAppear {
                    withAnimation {
                        showGuideMessage = false
                    }
                }
        }
    }
    
    @State private var showButton = false
    
    @ViewBuilder
    private var letsGo: some View {
        if currentTextIndex == TextConstants.introTexts.count - 1, showButton {
            Button {
                withAnimation {
                    pageManager.addPage()
                }
            } label: {
                Text("Let's Go")
                    .padding()
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .transition(.scale)
        }
    }
    
    private func next() {
        if currentTextIndex < TextConstants.introTexts.count - 1 {
            withAnimation {
                currentTextIndex += 1
                needStart = false
            }
        }
        if currentTextIndex == TextConstants.introTexts.count - 1 {
            hideGuideMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showButton = true
                }
            }
        }
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
