//
//  Posture.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI

struct Posture: View {
    var body: some View {
        VStack {
            detectPosture
        }
    }
    
    @State private var value = ""
    
    private var detectPosture: some View {
        ZStack(alignment: .bottom) {
            PostureRecognitionViewRefer(value: $value)
            VStack {
                Text(value)
                    .font(.title)
                    .padding()
                    .foregroundStyle(.red)
                    .background {
                        Color.black.opacity(0.5)
                    }
                Spacer()
                    .frame(height: 100)
            }
        }
    }
}

#Preview {
    Posture()
}
