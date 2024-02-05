//
//  Description.swift
//  Your Presentation
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
                Text(TextConstants.descriptionVoiceAndFaceNotice)
            }
            Section("POSTURE") {
                Text(TextConstants.descriptionPosture)
                Text(TextConstants.descriptionPostureNotice)
            }
            Section("NOTE") {
                Text("* If you have a stand, it is better to secure the iPad to the stand and make a presentation.")
                Text("** Coefficient of variation(CV) is a standardized measure of dispersion of a probability distribution or frequency distribution. It is defined as the ratio of the standard deviation to the mean. In this app, it is used to measure the instability of the data.")
            }
        }
        .fontWeight(.light)
        .toolbar { ToolbarItem(placement: .topBarLeading) { close } }
    }
    
    private var close: some View {
        Button("Close") {
            dismiss()
        }
    }
}

#Preview {
    Description()
        .preferredColorScheme(.dark)
}
