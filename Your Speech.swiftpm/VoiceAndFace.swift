//
//  VoiceAndFace.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI
import NaturalLanguage
import Charts

struct VoiceAndFace: View {
    private var speechManager = SpeechManager()
    
    @State private var recognizedText = ""
    @State private var similarity = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(TextConstants.voiceText)
                statusView(in: geometry.size)
                if playStatus != .finish {
                    Text(recognizedText)
                    Text(similarity)
                        .font(.largeTitle)
                }
                finish(in: geometry.size)
                changeByResult
                playButton
            }
            .frame(height: geometry.size.height)
        }
    }
    
    @State private var script = ""
    @State private var playStatus = PlayStatus.notPlay
    
    @ViewBuilder
    private func statusView(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay: 
            textInput
        case .play:
            playingVoiceAndFace(in: size)
        case .finish:
            finishOfFaceData()
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
    
    private var cv: String {
        var datas: [Float] = []
        speechManager.voiceDatas.forEach { data in
            datas.append(data.strength)
        }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    @State private var position = [LookAtPoint]()
    
    private func playingVoiceAndFace(in size: CGSize) -> some View {
        VStack {
            FaceRecognitionView(position: $position)
                .frame(width: size.width, height: size.height * 0.4)
            Chart(speechManager.voiceDatas, id: \.index) { data in
                LineMark(x: .value("Index", data.index), y: .value("Strength", data.strength))
            }
            .frame(width: size.width * 0.8, height: size.height * 0.25)
            Text("\(cv)")
        }
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }
    
    private var playButton: some View {
        PlayButton {
            speechManager.requestPermission()
            withAnimation {
                playStatus = .play
                speechManager.startRecording { text in
                    recognizedText = text
                }
            }
        } stopAction: {
            withAnimation {
                similarity(recognizedText, and: script)
                playStatus = .finish
                speechManager.stopRecording()
            }
        }
    }

    func similarity(_ input: String, and compare: String) {
        if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
            let shortInput = onlyString(input)
            let shortCompare = onlyString(compare)
            let distance = sentenceEmbedding.distance(between: shortInput, and: shortCompare)
            similarity += "Similarity: " + distance.description
        }
    }
    
    private func onlyString(_ text: String) -> String {
        let removeCondition = CharacterSet(charactersIn: ".,?!&-_\n\t")
        return text.components(separatedBy: removeCondition).joined().lowercased()
    }
    
    @State private var selectedResult = "Voice"
    private let results = ["Voice", "Face"]
    
    private func finish(in size: CGSize) -> some View {
        VStack {
            Picker("Choose you want", selection: $selectedResult) {
                ForEach(results, id: \.self) { result in
                    Text(result)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var changeByResult: some View {
        switch selectedResult {
        case "Voice":
            Text("Voice Chart")
        case "Face":
            Text("Face Chart")
        default:
            Text("Voice Chart")
        }
    }
    
    private func finishOfFaceData() -> some View {
        HStack {
            Chart(position, id: \.index) { item in
                LineMark(x: .value("Index", item.index), y: .value("X", item.x))
            }
            .frame(width: 300, height: 300)
            Chart(position, id: \.index) { item in
                LineMark(x: .value("Index", item.index), y: .value("Y", item.y))
            }
            .frame(width: 300, height: 300)
        }
    }
    
    
    
//    private func facePlaceHolder(in size: CGSize) -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 14)
//                .foregroundStyle(.white.gradient)
//                .padding(.vertical)
//                .frame(width: size.width, height: size.height * 0.77)
//            VStack {
//                Image(systemName: "face.smiling")
//                    .imageScale(.large)
//                    .font(.system(size: size.width * 0.3))
//                Text("Please tap start!!")
//                    .font(.largeTitle)
//            }
//            .foregroundStyle(.black)
//        }
//    }
}

#Preview {
    VoiceAndFace()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
