//
//  Face.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct Face: View {    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("when you speech...")
                        .font(.largeTitle)
                    placeHolder(in: geometry.size)
                    playButton
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .navigationTitle("Face")
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
            print("Start")
        } stopAction: {
            print("Stop")
        }
    }
}

#Preview {
    Face()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
        .tint(.gray)
}
