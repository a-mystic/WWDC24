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
            VStack(spacing: 40) {
                Spacer()
                currentText
                next
                Spacer()
                tapToStart
            }
        }
        .onTapGesture {
            withAnimation {
                currentTextIndex += 1
                needStart = false
            }
            if currentTextIndex == TextConstants.introTexts.count - 1 {
                hideGuideMessage = true
                withAnimation(.easeInOut(duration: 1)) {
                    showButton = true
                }
            }
        }
    }
    
    @State private var currentTextIndex = 0
    
    private var currentText: some View {
        Text(TextConstants.introTexts[currentTextIndex])
            .font(.largeTitle)
            .fontWeight(.black)
    }
    
    @State private var showGuideMessage = true
    @State private var needStart = true
    @State private var hideGuideMessage = false
    
    private var guideMessage: String {
        if needStart {
            return "Tap to start"
        } else {
            return "Tap to continue"
        }
    }
    
    private var tapToStart: some View {
        Text(guideMessage)
            .foregroundStyle(.white.opacity(0.8))
            .font(.largeTitle)
            .opacity(showGuideMessage ? 1 : 0)
            .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: showGuideMessage)
            .opacity(hideGuideMessage ? 0 : 1)
            .onAppear {
                withAnimation {
                    showGuideMessage = false
                }
            }
    }
    
    @State private var showButton = false
    
    @ViewBuilder
    private var next: some View {
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
                .font(.title)
                .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
            .transition(.scale)
        }
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
