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
                ScrollView {
                    VStack {
                        Text("when you have to speech...")
                            .font(.largeTitle)
                        next
                    }
            }
            .navigationTitle("Intro")
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
        .tint(.blue)
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
}
