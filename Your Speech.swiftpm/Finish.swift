//
//  Finish.swift
//  Your Speech
//
//  Created by a mystic on 12/23/23.
//

import SwiftUI

struct Finish: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white.gradient)
                    .overlay {
                        VStack(spacing: 40) {
                            Text("Thank you")
                                .font(.largeTitle)
                                .bold()
                            Text(TextConstants.finishText)
                                .font(.title)
                        }
                        .foregroundStyle(.black)
                    }
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
            }
        }
    }
}

#Preview {
    Finish()
        .preferredColorScheme(.dark)
}
