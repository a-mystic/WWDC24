//
//  CurrentProgressView.swift
//  Your Speech
//
//  Created by a mystic on 12/26/23.
//

import SwiftUI

struct CurrentProgressView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("VoiceAndFace") {
                Text("Not yet")
            }
            Section("Script") {
                Text("Not yet")
            }
            Section("Face") {
                Text("Not yet")
            }
            Section("Attitude") {
                Text("Not yet")
            }
        }
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
    CurrentProgressView()
}
