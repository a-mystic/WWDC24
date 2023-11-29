//
//  Intro.swift
//  Your Speech
//
//  Created by a mystic on 11/28/23.
//

import SwiftUI

struct Intro: View {
    @EnvironmentObject var pageManager: PageManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("when you have to speech...")
                    .navigationTitle("Intro")
                next
            }
        }
    }
    
    private var next: some View {
        Button {
            withAnimation {
                pageManager.addPage()
            }
        } label: {
            Text("Go to next page")
                .bold()
                .padding()
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
}
