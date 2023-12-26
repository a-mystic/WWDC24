//
//  CurrentProgressView.swift
//  Your Speech
//
//  Created by a mystic on 12/26/23.
//

import SwiftUI

struct CurrentProgressView: View {
    var body: some View {
        Form {
            Section("Voice") {
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
    }
}

#Preview {
    CurrentProgressView()
}
