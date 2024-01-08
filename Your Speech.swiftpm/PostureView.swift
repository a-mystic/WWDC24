//
//  PostureView.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct PostureView: View {
    @StateObject private var postureManager = PostureManager.shared
        
    var body: some View {
        GeometryReader { geometry in
            VStack {
                statusView(in: geometry.size)
                playButton
            }
            .overlay {
                loading
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
            result(in: size)
        }
    }
    
    private func placeHolder(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(Color.white.gradient)
                .frame(width: size.width * 0.9, height: size.height * 0.77)
                .padding()
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
        ZStack(alignment: .bottom) {
            PostureRecognitionViewRefer()
                .frame(width: size.width * 0.9, height: size.height * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(postureManager.currentPosture)
                .font(.title)
                .padding()
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.ultraThinMaterial)
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
            VStack {
                Spacer()
                Text("\(count)")
                    .font(.largeTitle)
                    .background {
                        Pie(endAngle: .degrees(countdownAngle * 360))
                            .foregroundStyle(.ultraThinMaterial)
                            .frame(width: size.width * 0.2, height: size.height * 0.2)
                    }
                    .onAppear {
                        startCountdown()
                    }
                Spacer()
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
            DispatchQueue.global(qos: .background).async {
                isLoading = true
                withAnimation {
                    playStatus = .play
                    isLoading = false
                }
            }
        } stopAction: {
            withAnimation {
                playStatus = .finish
            }
        }
    }
    
    private func result(in size: CGSize) -> some View {
        Text("the result is..")
    }
    
    @State private var isLoading = false

    @ViewBuilder
    private var loading: some View {
        if isLoading {
            ProgressView()
                .tint(.gray)
                .scaleEffect(2)
        }
    }
}

#Preview {
    PostureView()
        .preferredColorScheme(.dark)
}
