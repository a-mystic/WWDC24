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
            Text("This view is a..")
        case .play:
            recognizePosture(in: size)
        case .finish:
            Text("Your speech posture result is a..")
        }
    }
    
    private func recognizePosture(in size: CGSize) -> some View {
        ZStack(alignment: .top) {
//            RoundedRectangle(cornerRadius: 12)
            PostureRecognitionViewRefer()
                .frame(width: size.width * 0.9, height: size.height * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack {
                HStack {
                    Text("Mode: \(postureManager.currentPostureMode.rawValue)")
                        .foregroundStyle(.red)
                        .padding()
                        .background(Color.black.opacity(0.3))
                    Spacer()
                }
                .padding()
                Spacer()
                Text(postureManager.currentPosture)
                    .font(.title)
                    .padding()
                    .foregroundStyle(.red)
                    .background {
                        Color.black.opacity(0.3)
                    }
                Spacer()
                    .frame(height: 100)
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
