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
    @ObservedObject private var voiceManager = VoiceManager()
        
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.05) {
                if playStatus == .notPlay {
                    Text(TextConstants.voiceText)
                }
                contents(in: geometry.size)
                playButton
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay {
                loading
            }
        }
    }
    
    @State private var playStatus = PlayButton.PlayStatus.notPlay
    @State private var similarity = ""
    
    @ViewBuilder
    private func contents(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            textInput
        case .play:
            analyzer(in: size)
        case .finish:
            result(in: size)
        }
    }

    @State private var script = ""
    @State private var shakeCount: CGFloat = 0
    
    private var textInput: some View {
        TextField("Enter your script", text: $script, axis: .vertical)
            .padding()
            .foregroundStyle(.black)
            .background(Color.white.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .lineLimit(15...20)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 200)
            .shake(with: shakeCount)
            .tint(.black)
    }
    
    @StateObject private var faceManager = FaceManager.shared
    
    private func analyzer(in size: CGSize) -> some View {
        VStack(spacing: size.height * 0.05) {
            FaceRecognitionView()
                .frame(width: size.width * 0.7, height: size.height * 0.6)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            voiceChart
                .frame(width: size.width * 0.9, height: size.height * 0.15)
            Text(recognizedText)
                .font(.body)
        }
        .transition(.scale)
    }
    
    @State private var recognizedText = ""

    private var playButton: some View {
        PlayButton(playStatus: $playStatus) {
            if script.isEmpty || script.isContainEmoji {
                shakeCount = 0
                withAnimation(.easeInOut(duration: 1)) {
                    shakeCount = 7
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    isLoading = true
                    voiceManager.requestPermission()
                    withAnimation {
                        playStatus = .play
                        isLoading = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            voiceManager.startRecording { text in
                                recognizedText = text
                            }
                        }
                    }
                }
            }
        } stopAction: {
            withAnimation {
                similarity(recognizedText, and: script)
                voiceManager.stopRecording()
                playStatus = .finish
            }
        }
    }

    func similarity(_ input: String, and compare: String) {
        if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
            let shortInput = onlyString(input)
            let shortCompare = onlyString(compare)
            let distance = sentenceEmbedding.distance(between: shortInput, and: shortCompare)
            similarity = distance.description
        }
    }
    
    private func onlyString(_ text: String) -> String {
        let removeCondition = CharacterSet(charactersIn: ".,?!&-_\n\t")
        return text.components(separatedBy: removeCondition).joined().lowercased()
    }
    
    @State private var selectedResult = "😀 Face"
    private let results = ["😀 Face", "🎙️ Voice", "👀 Eyes"]
    
    private func result(in size: CGSize) -> some View {
        ScrollView {
            VStack {
                Text("Chart")
                    .font(.largeTitle)
                    .frame(width: size.width * 0.9, alignment: .leading)
                Picker("Choose you want", selection: $selectedResult) {
                    ForEach(results, id: \.self) { result in
                        Text(result)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: size.width * 0.9)
                charts(in: size)
                    .padding()
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(.brown.gradient)
                            .frame(width: size.width * 0.9)
                    }
                    .frame(height: size.height * 0.5)
                Text("FeedBack")
                    .font(.largeTitle)
                    .frame(width: size.width * 0.9, alignment: .leading)
                resultFeedback(in: size)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var feedbacks = ["1.", "2.", "3.", "4.", "5.", "6."]
    
    private var voiceCV: String {
        var datas: [Float] = []
        voiceManager.voiceDatas.forEach { datas.append($0.strength) }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    private var eyesCVX: String {
        var datas: [Float] = []
        faceManager.lookAtPoint.forEach { datas.append($0.x) }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    private var eyesCVY: String {
        var datas: [Float] = []
        faceManager.lookAtPoint.forEach { datas.append($0.y) }
        if let returncv = datas.coefficientOfVariation() {
            return "\(returncv)"
        } else {
            return ""
        }
    }
    
    @ViewBuilder
    private func charts(in size: CGSize) -> some View {
        switch selectedResult {
        case "😀 Face":
            faceChart(in: size)
        case "🎙️ Voice":
            VStack {
                voiceChart
                Text("CV: \(voiceCV)")
                Text("Similarity: \(similarity)")
            }
            .frame(width: size.width * 0.9, height: size.height * 0.3)
        case "👀 Eyes":
            VStack {
                eyesChart(in: size)
                HStack {
                    Text("CVX: \(eyesCVX)")
                    Text("CVY: \(eyesCVY)")
                }
            }
        default:
            Text("Error")
        }
    }
    
    private var faceDatas: [String:Int] {
        var datas = [String:Int]()
        faceManager.faceEmotions.forEach { key, value in
            if key != "😐" && key != "😮" {
                datas[key] = value
            }
        }
        return datas
    }
    
    private func faceChart(in size: CGSize) -> some View {
        Chart(faceDatas.sorted(by: <), id: \.key) { emotion in
            BarMark(x: .value("emotion", emotion.key), y: .value("value", emotion.value))
                .foregroundStyle(colorByEmotion(emotion.key))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: size.width * 0.8, height: size.height * 0.4)
    }
    
    private func colorByEmotion(_ key: String) -> Color {
        switch key {
        case "😡":
            return EmotionColor.veryAngry
        case "😠":
            return EmotionColor.angry
        case "😐", "😮":
            return EmotionColor.idle
        case "🙂":
            return EmotionColor.smile
        case "😁":
            return EmotionColor.verySmile
        case "😛":
            return EmotionColor.tongue
        default:
            return EmotionColor.idle
        }
    }
    
    
    private var voiceChart: some View {
        Chart(voiceManager.voiceDatas) { data in
            LineMark(x: .value("Index", data.id), y: .value("Strength", data.strength))
        }
        .foregroundStyle(faceManager.faceColor)
    }
    
    private func eyesChart(in size: CGSize) -> some View {
        HStack(spacing: 40) {
            Chart(faceManager.lookAtPoint) { point in
                LineMark(x: .value("Index", point.id), y: .value("X", point.x))
            }
            .frame(width: size.width * 0.3, height: size.height * 0.3)
            Chart(faceManager.lookAtPoint) { point in
                LineMark(x: .value("Index", point.id), y: .value("Y", point.y))
            }
            .frame(width: size.width * 0.3, height: size.height * 0.3)
        }
        .foregroundStyle(.white)
    }
    
    private func resultFeedback(in size: CGSize) -> some View {
        VStack {
            Text("Your result")
            ForEach(feedbacks, id: \.self) { feedback in
                Text(feedback)
                Divider()
            }
        }
        .foregroundStyle(.black)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white.gradient)
                .frame(width: size.width * 0.9)
        }
    }
    
    @State private var isLoading = false

    @ViewBuilder
    private var loading: some View {
        if isLoading {
            ProgressView()
                .tint(.gray)
                .scaleEffect(2)
        }
    }
}

#Preview {
    VoiceAndFace()
        .environmentObject(PageManager())
        .preferredColorScheme(.dark)
}
