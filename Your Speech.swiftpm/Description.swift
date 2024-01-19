//
//  Description.swift
//  Your Speech
//
//  Created by a mystic on 12/26/23.
//

import SwiftUI

struct Description: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("APP") {
                Text(TextConstants.descriptionApp)
            }
            Section("VOICE&FACE") {
                Text(TextConstants.descriptionVoiceAndFace)
            }
            Section("POSTURE") {
                Text(TextConstants.descriptionPosture)
            }
        }
        .fontWeight(.light)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    Description()
        .preferredColorScheme(.dark)
}
