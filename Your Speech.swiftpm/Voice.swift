//
//  Script.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI
import NaturalLanguage
import Charts

struct Voice: View {
    private var speechManager = SpeechManager()
    
    @State private var recognizedText = ""
    @State private var similarity = ""
    
    var body: some View {
        VStack {
            Text(TextConstants.voiceText)
                .font(.largeTitle)
                .bold()
            voiceField
            Text(recognizedText)
            Text(similarity)
                .font(.largeTitle)
            playButton
        }
    }
    
    @State private var script = ""
    @State private var playStatus = PlayStatus.notPlay
    
    @ViewBuilder
    private var voiceField: some View {
        switch playStatus {
        case .notPlay: textInput
        case .play:
            playingVoice()
        case .finish:
            VStack {
                playingVoice()
                Text("Finish go next page!!!!")
            }
        }
    }
    
    private var textInput: some View {
        TextField("Enter your script", text: $script, axis: .vertical)
            .padding()
            .foregroundStyle(.black)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .lineLimit(15...20)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 200)
    }
    
    private func playingVoice() -> some View {
        VStack {
            Chart(speechManager.voiceDatas, id: \.index) { data in
                LineMark(x: .value("Index", data.index), y: .value("Strength", data.strength))
            }
            .frame(width: 300, height: 300)
            Text("\(calcMeanOfDeviation(speechManager.voiceDatas))")
        }
    }
    
    private func calcMeanOfDeviation(_ datas: [VoiceModel]) -> Float {
        let mean = calcMean(datas)
        let deviations = datas.map { abs($0.strength - mean) }
        let sumOfDeviations = deviations.reduce(0, +)
        return sumOfDeviations / Float(datas.count)
    }
    
    private func calcMean(_ datas: [VoiceModel]) -> Float {
        var sum: Float = 0
        for data in datas {
            sum += data.strength
        }
        return sum / Float(datas.count)
    }
    
    private var playButton: some View {
        PlayButton {
            speechManager.requestPermission()
            playStatus = .play
            speechManager.startRecording { text in
                recognizedText = text
            }
        } stopAction: {
            calcSimilarity(recognizedText, and: script)
            playStatus = .finish
            speechManager.stopRecording()
            print(speechManager.voiceDatas)
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
    Voice()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
