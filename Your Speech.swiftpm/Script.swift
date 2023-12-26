//
//  Script.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI
import NaturalLanguage

struct Script: View {
    private let speechManager = SpeechManager()
    
    @State private var recognizedText = ""
    @State private var similarity = ""
    
    var body: some View {
        VStack {
            Text("input your script and test your part of all script.")
            inputField
            Text(recognizedText)
            Text(similarity)
                .font(.largeTitle)
            playButton
        }
    }
    
    @State private var script = ""
    
    private var inputField: some View {
        TextField("Enter your script", text: $script, axis: .vertical)
            .padding()
            .foregroundStyle(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .lineLimit(6)
            .padding()
            .lineLimit(4...10)
    }
    
    private var playButton: some View {
        PlayButton {
            speechManager.requestPermission()
            speechManager.startRecording { text in
                recognizedText = text
            }
        } stopAction: {
            calcSimilarity(recognizedText, and: script)
            speechManager.stopRecording()
        }
    }

    func calcSimilarity(_ input: String, and compare: String) {
        if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
            let shortInput = makeOnlyString(input)
            let shortCompare = makeOnlyString(compare)
            let distance = sentenceEmbedding.distance(between: shortInput, and: shortCompare)
            similarity += "Similarity: " + distance.description
        }
    }
    
    private func makeOnlyString(_ text: String) -> String {
        let removeCondition = CharacterSet(charactersIn: ".,?!&-_\n\t")
        return text.components(separatedBy: removeCondition).joined().lowercased()
    }
}

#Preview {
    Script()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
