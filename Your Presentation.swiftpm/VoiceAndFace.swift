//
//  VoiceAndFace.swift
//  Your Presentation
//
//  Created by a mystic on 11/29/23.
//
// The magic numbers used in the code were obtained through numerous tests.

import SwiftUI
import NaturalLanguage
import Charts

struct VoiceAndFace: View {
    @ObservedObject private var voiceManager = VoiceManager()
    
    @EnvironmentObject var pageManager: PageManager
        
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.05) {
                contents(in: geometry.size)
                playButton
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay {
                loading
            }
            .alert("Voice Error", isPresented: $voiceManager.showVoiceError) {
                Button("Okay", role: .cancel) {
                    pageManager.addPage()
                }
            } message: {
                Text(voiceManager.voiceErrorStatus.errorMessage)
            }
            .alert("Face Error", isPresented: $faceManager.showfaceError) {
                Button("Okay", role: .cancel) {
                    pageManager.addPage()
                }
            } message: {
                Text(faceManager.faceErrorStatus.errorMessage)
            }
        }
    }
        
    @ViewBuilder
    private func contents(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            textAndInput(in: size)
        case .play:
            analyzer(in: size)
        case .finish:
            result(in: size)
        }
    }

    @State private var script = ""
    @State private var shakeCount: CGFloat = 0
    
    private func textAndInput(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(Color.white.gradient)
            VStack(spacing: size.height * 0.05) {
                Text(TextConstants.voiceAndFaceText)
                    .multilineTextAlignment(.leading)
                    .frame(width: size.width * 0.8)
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundStyle(.black)
                TextField("Enter the parts of your script that you think are important", text: $script, axis: .vertical)
                    .lineLimit(10...10)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Material.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, size.width * 0.1)
                    .shake(with: shakeCount)
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
        .frame(width: textInputSize(in: size).width, height: textInputSize(in: size).height)
    }
    
    private func textInputSize(in size: CGSize) -> (width: CGFloat, height: CGFloat) {
        return (width: min(size.width * 0.9, size.height * 0.9), height: min(size.height * 0.8, size.width * 0.8))
    }
    
    @StateObject private var faceManager = FaceManager.shared
    
    private func analyzer(in size: CGSize) -> some View {
        VStack(spacing: size.height * 0.03) {
            Spacer()
            FaceRecognitionView()
                .frame(width: recognitionViewFrame(in: size).width, height: recognitionViewFrame(in: size).height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottom) { subtitle }
            voiceChart
                .frame(width: size.width * 0.9, height: size.height * 0.2)
                .padding()
                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .transition(.scale)
    }
    
    private func recognitionViewFrame(in size: CGSize) -> (width: CGFloat, height: CGFloat) {
        return (width: min(size.width * 0.7, size.height * 0.7), height: max(size.height * 0.55, size.width * 0.35))
    }
    
    @ViewBuilder
    private var subtitle: some View {
        if !recognizedText.isEmpty {
            Text(recognizedText)
                .font(.body)
                .fontWeight(.light)
                .foregroundStyle(.white)
                .padding()
                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @State private var recognizedText = ""
    @State private var playStatus = PlayButton.PlayStatus.notPlay

    private var playButton: some View {
        PlayButton(playStatus: $playStatus) {
            if script.isEmpty || script.isContainEmoji {
                shakeCount = 0
                withAnimation(.easeInOut(duration: 1)) {
                    shakeCount = 6
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    isLoading = true
                    voiceManager.requestPermission {
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
            }
        } stopAction: {
            similar(recognizedText, to: script)
            withAnimation {
                voiceManager.stopRecording()
                playStatus = .finish
            }
        }
    }
    
    @State private var similarity: Float?

    private func similar(_ input: String, to compare: String) {
        if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
            let shortInput = onlyString(input)
            let shortCompare = onlyString(compare)
            let distance = sentenceEmbedding.distance(between: shortInput, and: shortCompare)
            if let distance = Float(distance.description) {
                similarity = distance
            } else {
                similarity = nil
            }
        }
    }
    
    private func onlyString(_ text: String) -> String {
        let removeCondition = CharacterSet(charactersIn: ".,?!&-_ \n\t")
        let components = text.components(separatedBy: removeCondition).filter { !$0.isEmpty }
        return components.joined(separator: " ").lowercased()
    }
    
    @State private var selectedResultState: ResultChartStatus = .face
    private let resultStates: [ResultChartStatus] = [.face, .voice, .eyes]
    
    private func result(in size: CGSize) -> some View {
        ScrollView {
            VStack(spacing: size.height * 0.03) {
                Text("Chart")
                    .font(.largeTitle)
                    .frame(width: size.width * 0.9, alignment: .leading)
                Picker("Choose you want", selection: $selectedResultState) {
                    ForEach(resultStates, id: \.self) { state in
                        Text(state.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: size.width * 0.9)
                charts(in: size)
                    .padding()
                    .padding(.vertical)
                    .background {
                        SpecialBrownBackground()
                            .frame(width: size.width * 0.9)
                    }
                Text("FeedBack")
                    .font(.largeTitle)
                    .frame(width: size.width * 0.9, alignment: .leading)
                feedback(in: size)
            }
        }
        .scrollIndicators(.hidden)
    }
        
    @ViewBuilder
    private func charts(in size: CGSize) -> some View {
        switch selectedResultState {
        case .face:
            faceChart
                .frame(width: size.width * 0.8, height: size.height * 0.45)
        case .voice:
            VStack {
                voiceChart
                analyzedVoiceDatas(in: size)
            }
            .frame(width: size.width * 0.8, height: size.height * 0.45)
        case .eyes:
            VStack {
                eyesChart
                analyzedEyesDatas(in: size)
            }
            .frame(width: size.width * 0.8, height: size.height * 0.45)
        }
    }
    
    private enum ResultChartStatus: String {
        case face = "😀 Face"
        case voice = "🎙️ Voice"
        case eyes = "👀 Eyes"
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
    
    private var faceChart: some View {
        Chart(faceDatas.sorted(by: <), id: \.key) { emotion in
            BarMark(x: .value("emotion", emotion.key), y: .value("value", emotion.value))
                .foregroundStyle(colorByEmotion(emotion.key))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
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
    
    private var voiceCV: Float? {
        var datas: [Float] = []
        voiceManager.voiceDatas.forEach { datas.append($0.strength) }
        // Remove unnecessary data.
        let drop = Int(Double(datas.count) * 0.04)
        var shortFormDatas = Array(datas.dropFirst(drop))
        shortFormDatas = Array(shortFormDatas.dropLast(drop))
        if let returncv = shortFormDatas.coefficientOfVariation() {
            return returncv
        } else {
            return nil
        }
    }
    
    private var similarityPercent: String {
        if let similarity = similarity {
            let percent = (1 - similarity / 2) * 100
            return String(format: "%.2f", percent) + "%"
        } else {
            return "Not measurable."
        }
    }
    
    private func analyzedVoiceDatas(in size: CGSize) -> some View {
        VStack(alignment: .leading) {
            if let voiceCV = voiceCV {
                Text("Coefficient of variation: \(String(format: "%.2f", voiceCV))")
                Text("Similarity: \(similarityPercent)")
            }
        }
        .font(.body)
        .foregroundStyle(.black)
        .padding()
        .background(Color.white.gradient, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var eyesChart: some View {
        HStack(spacing: 40) {
            Chart(faceManager.lookAtPoint) { point in
                LineMark(x: .value("Index", point.id), y: .value("X", point.x))
            }
            Chart(faceManager.lookAtPoint) { point in
                LineMark(x: .value("Index", point.id), y: .value("Y", point.y))
            }
        }
        .foregroundStyle(.white)
    }
    
    private var eyesCVX: Float? {
        var datas: [Float] = []
        faceManager.lookAtPoint.forEach { datas.append($0.x) }
        if let returncv = datas.coefficientOfVariation() {
            return returncv
        } else {
            return nil
        }
    }
    
    private var eyesCVY: Float? {
        var datas: [Float] = []
        faceManager.lookAtPoint.forEach { datas.append($0.y) }
        if let returncv = datas.coefficientOfVariation() {
            return returncv
        } else {
            return nil
        }
    }
    
    private var blinkRatio: Float {
        let sum = faceManager.blink + faceManager.notBlink
        return faceManager.blink / sum
    }
    
    private func analyzedEyesDatas(in size: CGSize) -> some View {
        VStack(alignment: .leading) {
            if let eyesCVX = eyesCVX, let eyesCVY = eyesCVY {
                Text("Coefficient of variation: \(String(format: "%.2f", (eyesCVX + eyesCVY) / 2))")
                Text("Blink ratio: \(String(format: "%.2f", blinkRatio * 100))%")
            }
        }
        .font(.body)
        .foregroundStyle(.black)
        .padding()
        .background(Color.white.gradient, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @State private var feedbacks: [String] = []
    @State private var score = ""
    
    @ViewBuilder
    private func feedback(in size: CGSize) -> some View {
        let divider = Divider().background(.black)
        VStack {
            Text("Your detected problems")
            divider
            if feedbacks.isEmpty {
                ProgressView().tint(.gray)
                divider
            } else {
                ForEach(feedbacks.indices, id: \.self) { index in
                    if let condition = feedbacks.first, condition == "nil" {
                        Text("No problem")
                    } else {
                        Text("\(index + 1). \(feedbacks[index])")
                    }
                    divider
                }
            }
            HStack {
                Text("Your score: ")
                if score.isEmpty {
                    ProgressView().tint(.gray)
                } else {
                    Text(score)
                }
            }
        }
        .foregroundStyle(.black)
        .font(.body)
        .fontWeight(.black)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white.gradient)
                .frame(width: size.width * 0.9)
        }
        .onAppear {
            let dispatchGroup = DispatchGroup()
            DispatchQueue.global(qos: .background).async(group: dispatchGroup) {
                faceFeedback()
                voiceFeedback()
                eyesFeedback()
            }
            dispatchGroup.notify(queue: .global(qos: .background)) {
                if feedbacks.isEmpty {
                    feedbacks.append("nil")
                }
                DispatchQueue.main.async {
                    evaluate()
                }
            }
        }
    }
    
    private func faceFeedback() {
        let sum = faceManager.faceEmotions.values.reduce(0, +)
        faceManager.faceEmotions.forEach { key, value in
            let ratio = Double(value) / Double(sum)
            if key != "😐" && key != "😮" {
                if (key == "🙂" || key == "😁") && ratio > 0.25 {
                    feedbacks.append(convertEmoji(key))
                } else if key != "🙂" && key != "😁" && ratio > 0.15 {
                    feedbacks.append(convertEmoji(key))
                }
            }
        }
    }
    
    private func convertEmoji(_ emoji: String) -> String {
        switch emoji {
        case "😁":
            return "😁 Too much very smile"
        case "🙂":
            return "🙂 Too much smile"
        case "😡":
            return "😡 Too much very frown"
        case "😠":
            return "😠 Too much frown"
        case "😛":
            return "😛 Too much tongue out"
        default:
            return "😱 Unrecognizable emotions"
        }
    }
    
    private func voiceFeedback() {
        if let voiceCV = voiceCV, voiceCV > 1.7 {
            feedbacks.append("Voice is unstable")
        }
        if let similarity = similarity, similarity > 0.95 {
            feedbacks.append("Couldn't present the script properly")
        }
    }
    
    private func eyesFeedback() {
        if let eyesCVX = eyesCVX, let eyesCVY = eyesCVY {
            if ((eyesCVX + eyesCVY) / 2) > 5.1 {
                feedbacks.append("Moved eyes too much")
            }
        }
        if blinkRatio > 0.23 {
            feedbacks.append("Blinked too much")
        }
    }
    
    @StateObject private var feedbackScore = FeedbackScore.shared
    
    private func evaluate() {
        let count = feedbacks.count
        feedbackScore.score += count
        switch count {
        case 0, 1, 2:
            score = "😀 Very Good"
        case 3, 4:
            score = "🙂 Good"
        default:
            score = "😢 Not Good"
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
