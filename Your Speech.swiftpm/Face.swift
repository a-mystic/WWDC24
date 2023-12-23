//
//  Face.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct Face: View {
    @EnvironmentObject var pageManager: PageManager
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("when you speech...")
                            .font(.largeTitle)
                        placeHolder(in: geometry.size)
                        stateButton
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .navigationTitle("Intro")
        }
    }
    
    private func placeHolder(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.gray.opacity(0.44).gradient)
                .padding(.vertical)
                .frame(width: size.width, height: size.height * 0.77)
            VStack {
                Image(systemName: "face.smiling")
                    .imageScale(.large)
                    .font(.system(size: size.width * 0.3))
                Text("Please tap start!!")
                    .font(.largeTitle)
            }
        }
    }
    
    private enum ButtonState: String {
        case start = "Start"
        case stop = "Stop"
        case next = "Go to next page"
    }
    
    @State private var buttonState = ButtonState.start
    
    private var stateButton: some View {
        Button {
            withAnimation {
                switch buttonState {
                case .start: buttonState = .stop
                case .stop: buttonState = .next
                case .next: pageManager.addPage()
                }
            }
        } label: {
            Text(buttonState.rawValue)
                .bold()
                .padding()
                .font(.title)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }
}

#Preview {
    Face()
}
