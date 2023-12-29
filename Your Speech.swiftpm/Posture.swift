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
            Text(value)
                .font(.largeTitle)
                .padding()
                .foregroundStyle(.red)
                .background {
                    Color.black.opacity(0.5)
                }
        }
    }
}

#Preview {
    Posture()
}
