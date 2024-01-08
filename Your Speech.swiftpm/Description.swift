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
            Section("App") {
                Text("Not yet")
            }
            Section("Voice&Face") {
                Text("Not yet, the voice chart have some secret.")
            }
            Section("Posture") {
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
    Description()
}
