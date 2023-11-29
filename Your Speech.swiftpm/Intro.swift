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
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("when you have to speech...")
                            .navigationTitle("Intro")
                        next
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
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
        .tint(.blue)
    }
}

#Preview {
    Intro()
        .environmentObject(PageManager())
}
