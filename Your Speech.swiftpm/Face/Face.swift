//
//  Face.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct Face: View {     // consider adding progress view.
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text("when you speech...")
                        .font(.largeTitle)
                    faceTracking(in: geometry.size)
                    playButton
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    enum PlayStatus {
        case notPlay
        case play
        case finish
    }
    
    @State private var playStatus = PlayStatus.notPlay
    
    @ViewBuilder
    private func faceTracking(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            placeHolder(in: size)
        case .play:
            FaceRecognitionView()
                .frame(width: size.width, height: size.height * 0.77)
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
        case .finish:
            finish(in: size)
        }
    }
    
    private func placeHolder(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.white.gradient)
                .padding(.vertical)
                .frame(width: size.width, height: size.height * 0.77)
            VStack {
                Image(systemName: "face.smiling")
                    .imageScale(.large)
                    .font(.system(size: size.width * 0.3))
                Text("Please tap start!!")
                    .font(.largeTitle)
            }
            .foregroundStyle(.black)
        }
    }
    
    private var playButton: some View {
        PlayButton {
            withAnimation {
                playStatus = .play
            }
        } stopAction: {
            withAnimation {
                playStatus = .finish
            }
        }
    }
    
    private func finish(in size: CGSize) -> some View {
        VStack {
            Image(systemName: "chart.bar.xaxis.ascending")
                .imageScale(.large)
                .font(.system(size: size.width * 0.3))
            Text("some finish comment & feedback.")
        }
    }
}

#Preview {
    Face()
        .environmentObject(PageManager())
        .environmentObject(FaceManager())
        .preferredColorScheme(.dark)
}
