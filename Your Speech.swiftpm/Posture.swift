//
//  Posture.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct Posture: View {
    @EnvironmentObject var postureManager: PostureManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                statusView(in: geometry.size)
                playButton
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    @ViewBuilder
    private func statusView(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            VStack {
                Text("This view is a..")
                placeHolder(in: size)
            }
        case .play:
            recognizePosture(in: size)
        case .finish:
            Text("Your speech posture result is a..")
        }
    }
    
    private func placeHolder(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(Color.brown.gradient)
                .padding(.vertical)
                .frame(width: size.width, height: size.height * 0.77)
            VStack {
                Image(systemName: "figure.arms.open")
                    .imageScale(.large)
                    .font(.system(size: size.width * 0.3))
                Text("Please tap start!!")
                    .font(.largeTitle)
            }
            .foregroundStyle(.black)
        }
    }
    
    private func recognizePosture(in size: CGSize) -> some View {
        ZStack {
            PostureRecognitionViewRefer()
                .frame(width: size.width * 0.9, height: size.height * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack {
                Spacer()
                Text(postureManager.currentPosture)
                    .font(.largeTitle)
                    .padding()
                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .padding()
                            .foregroundStyle(.black.gradient.opacity(0.4))
                    }
            }
            countdownAnimation(in: size)
        }
    }
    
    @State private var count = 5
    @State private var isTimerShow = true
    @State private var countdownAngle: Double = 0
    
    @ViewBuilder
    private func countdownAnimation(in size: CGSize) -> some View {
        if postureManager.isChanging && isTimerShow {
            Text("\(count)")
                .font(.largeTitle)
                .background {
                    Pie(endAngle: .degrees(countdownAngle * 360))
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(width: size.width * 0.2, height: size.height * 0.2)
                }
            .onAppear {
                startCountdown()
            }
        }
    }
    
    private func startCountdown() {
        withAnimation(.linear(duration: 1)) {
            countdownAngle = 1
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownAngle = 0
            count -= 1
            if count == 0 {
                timer.invalidate()
                isTimerShow = false
            }
            withAnimation(.linear(duration: 1)) {
                countdownAngle = 1
            }
        }
    }
    
    @State private var playStatus = PlayButton.PlayStatus.notPlay
    
    private var playButton: some View {
        PlayButton(playStatus: $playStatus) {
            withAnimation {
                playStatus = .play
            }
        } stopAction: {
            withAnimation {
                playStatus = .finish
            }
        }
    }
}

#Preview {
    Posture()
        .preferredColorScheme(.dark)
        .environmentObject(PostureManager())
}
