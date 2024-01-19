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
                currentText
                nextPage
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
    
    private var currentText: some View {
        Text(TextConstants.introTexts[currentTextIndex])
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .fontWeight(.black)
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
    private var nextPage: some View {
        if currentTextIndex == TextConstants.introTexts.count - 1, showButton {
            Button {
                withAnimation {
                    pageManager.addPage()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("Let's Go")
                }
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
            withAnimation(.easeInOut(duration: 0.5)) {
                showButton = true
            }
        }
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
