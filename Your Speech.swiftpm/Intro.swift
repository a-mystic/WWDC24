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
                text
                next
                Spacer()
                tapToStart
            }
        }
        .onTapGesture {
            if needTap {
                startAnimation()
                needTap = false
            }
        }
//        .alert("Error", isPresented: $alertIsShow) {
//            Button("okay", role: .cancel) {
//                print("Okay")
//            }
//        } message: {
//            Text("Hello error")
//        }
//        .onAppear(perform: {
//            alertIsShow = true
//        })
    }
    
//    @State private var alertIsShow = false
    
    @State private var currentTextIndex = 0
    @State private var isAnimation = true
    private var currentText: String {
        TextConstants.introTexts[currentTextIndex]
    }
    
    private var text: some View {
        Text(currentText)
            .font(.largeTitle)
            .fontWeight(.black)
            .opacity(isAnimation ? 1 : 0)
    }
    
    @State private var needTap = false
    
    private var tapToStart: some View {
        Text("Tap to start")
            .foregroundStyle(.white.opacity(0.8))
            .font(.largeTitle)
            .opacity(needTap ? 1 : 0)
            .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: needTap)
            .opacity(needTap ? 1 : 0)
            .onAppear {
                withAnimation {
                    needTap = true
                }
            }
    }
    
    private func startAnimation() {
        isAnimation = false
        withAnimation(.linear(duration: 4)) {
            isAnimation = true
        }
        currentTextIndex += 1
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
