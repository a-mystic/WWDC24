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
    @ObservedObject private var speechManager = VoiceManager()
    
    @State private var recognizedText = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                Text(TextConstants.voiceText)
                statusView(in: geometry.size)
                if playStatus != .finish {
                    Text(recognizedText)
                }
                playButton
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    @State private var playStatus = PlayButton.PlayStatus.notPlay
    @State private var similarity = ""
    
    @ViewBuilder
    private func statusView(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            textInput
        case .play:
            playingVoiceAndFace(in: size)
        case .finish:
            finish(in: size)
        }
    }

    @State private var script = ""
    @State private var shakeCount: CGFloat = 0
    
    private var textInput: some View {
        TextField("Enter your script", text: $script, axis: .vertical)
            .padding()
            .foregroundStyle(.black)
            .background(Color.brown.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .lineLimit(15...20)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 200)
            .shake(with: shakeCount)
    }
    
    @EnvironmentObject var faceManager: FaceManager
    
    private func playingVoiceAndFace(in size: CGSize) -> some View {
        VStack {
            FaceRecognitionView()
                .frame(width: size.width * 0.6, height: size.height * 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            finishOfVoiceData()
        }
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }
    
    private var playButton: some View {
        PlayButton(playStatus: $playStatus) {
            if script.isEmpty {
                shakeCount = 0
                withAnimation(.easeInOut(duration: 1)) {
                    shakeCount = 5
                }
            } else {
                speechManager.requestPermission()
                withAnimation {
                    speechManager.startRecording { text in
                        recognizedText = text
                    }
                    playStatus = .play
                }
            }
        } stopAction: {
            withAnimation {
                similarity(recognizedText, and: script)
                speechManager.stopRecording()
                playStatus = .finish
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
            changeByResult
        }
    }
    
    private var voiceCV: String {
        var datas: [Float] = []
        speechManager.voiceDatas.forEach { datas.append($0.strength) }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    private var faceCVX: String {
        var datas: [Float] = []
        faceManager.lookAtPoint.forEach { datas.append($0.x) }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    private var faceCVY: String {
        var datas: [Float] = []
        faceManager.lookAtPoint.forEach { datas.append($0.y) }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    private var changeByResult: some View {
        switch selectedResult {
        case "Voice":
            VStack {
                finishOfVoiceData()
                Text("CV: \(voiceCV)")
                Text("Similarity: \(similarity)")
            }
        case "Face":
            VStack {
                finishOfFaceData()
                HStack {
                    Text("CVX: \(faceCVX)")
                    Text("CVY: \(faceCVY)")
                }
            }
        default:
            Text("Error")
        }
    }
    
    private func finishOfVoiceData() -> some View {
        Chart(speechManager.voiceDatas) { data in
            LineMark(x: .value("Index", data.id), y: .value("Strength", data.strength))
        }
        .frame(width: 300, height: 300)
    }
    
    @State private var chartX = [LookAtPoint]()
    @State private var chartY = [LookAtPoint]()
    
    private func finishOfFaceData() -> some View {
        HStack {
            Chart(chartX) { item in
                LineMark(x: .value("Index", item.id), y: .value("X", item.x))
            }
            .frame(width: 300, height: 300)
            Chart(chartY) { item in
                LineMark(x: .value("Index", item.id), y: .value("Y", item.y))
            }
            .frame(width: 300, height: 300)
        }
        .onAppear {
            chartX = []
            chartY = []
            withAnimation(.easeInOut(duration: 3)) {
                faceManager.lookAtPoint.forEach { point in
                    chartX.append(point)
                    chartY.append(point)
                }
            }
        }
    }
}

#Preview {
    VoiceAndFace()
        .environmentObject(PageManager())
        .environmentObject(FaceManager())
        .preferredColorScheme(.dark)
}
