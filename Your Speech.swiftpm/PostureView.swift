//
//  PostureView.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//
// The magic numbers used in the code were obtained through numerous tests.

import SwiftUI
import Charts

struct PostureView: View {
    @StateObject private var postureManager = PostureManager.shared    
    @EnvironmentObject var pageManager: PageManager
        
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.04) {
                contents(in: geometry.size)
                playButton
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .alert("Posture Error", isPresented: $postureManager.showpostureError) {
                Button("Okay", role: .cancel) {
                    pageManager.addPage()
                }
            } message: {
                Text(postureManager.postureErrorStatus.errorMessage)
            }
        }
    }
    
    @ViewBuilder
    private func contents(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            placeHolder(in: size)
        case .play:
            ZStack(alignment: .topLeading) {
                postureRecognizer(in: size)
                currentMode
            }
        case .finish:
            analysis(in: size)
        }
    }
    
    private func placeHolder(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(Color.white.gradient)
                .frame(width: size.width * 0.9, height: size.height * 0.8)
                .padding()
            VStack(spacing: size.height * 0.04) {
                Image(systemName: "figure.arms.open")
                    .imageScale(.large)
                    .font(.system(size: size.width * 0.3))
                Text(TextConstants.postureText)
                    .multilineTextAlignment(.leading)
                    .frame(width: size.width * 0.8)
                    .font(.body)
                    .fontWeight(.light)
            }
            .foregroundStyle(.black)
            .overlay { loading }
        }
    }
    
    private func postureRecognizer(in size: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            PostureRecognitionView()
                .frame(width: size.width * 0.9, height: size.height * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            if !postureManager.currentPostureMessage.isEmpty {
                Text(postureManager.currentPostureMessage)
                    .font(.title)
                    .padding()
                    .foregroundStyle(.white)
                    .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .opacity(postureManager.currentPostureMode == .ready ? 1 : 0)
            }
        }
        .overlay { countdownAnimation(in: size) }
        .transition(.scale)
    }
    
    @State private var count = 5
    @State private var isTimerShow = true
    @State private var countdownAngle: Double = 0
    
    @ViewBuilder
    private func countdownAnimation(in size: CGSize) -> some View {
        if postureManager.isChanging && isTimerShow {
            Text("\(count)")
                .font(.largeTitle)
                .background {
                    Pie(endAngle: .degrees(countdownAngle * 360))
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(width: size.width * 0.2, height: size.height * 0.2)
                }
                .onAppear {
                    startCountdown()
                }
        }
    }
    
    private func startCountdown() {
        withAnimation(.linear(duration: 1)) {
            countdownAngle = 1
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownAngle = 0
            count -= 1
            if count == 0 {
                timer.invalidate()
                isTimerShow = false
            }
            withAnimation(.linear(duration: 1)) {
                countdownAngle = 1
            }
        }
    }
    
    private var currentMode: some View {
        Text("Current Mode: \(postureManager.currentPostureMode.rawValue)")
            .font(.body)
            .padding()
            .foregroundStyle(.white)
            .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @State private var playStatus = PlayButton.PlayStatus.notPlay
    
    @ViewBuilder
    private var playButton: some View {
        if #available(iOS 17.0, *) {
            PlayButton(playStatus: $playStatus) {
                DispatchQueue.global(qos: .background).async {    // real
                    isLoading = true
                    withAnimation {
                        playStatus = .play
                        isLoading = false
                    }
                }
            } stopAction: {
                withAnimation {
                    playStatus = .finish
                }
            }
            .onChange(of: postureManager.currentPostureMode) {
                autoFinish()
            }
        } else {
            PlayButton(playStatus: $playStatus) {
                DispatchQueue.global(qos: .background).async {
                    isLoading = true
                    withAnimation {
                        playStatus = .play
                        isLoading = false
                    }
                }
            } stopAction: {
                withAnimation {
                    playStatus = .finish
                }
            }
            .onChange(of: postureManager.currentPostureMode) { _ in
                autoFinish()
            }
        }
    }
    
    private func autoFinish() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 35) {
            if playStatus != .finish {
                withAnimation {
                    playStatus = .finish
                }
            }
        }
    }
    
    @State private var handCV: Float?
    @State private var footCV: Float?
    
    private func analysis(in size: CGSize) -> some View {
        ScrollView {
            VStack(spacing: size.height * 0.05) {
                Text("good/bad")
                    .frame(width: size.width * 0.9, alignment: .leading)
                goodAndNotGoodChart(in: size)
                Text("recognized Postures")
                    .frame(width: size.width * 0.9, alignment: .leading)
                recognizedPostureChart(in: size)
                DisclosureGroup("Hand") {
                    handChart(in: size)
                }
                .frame(width: size.width * 0.9)
                .tint(.white)
                DisclosureGroup("Foot") {
                    footChart(in: size)
                }
                .frame(width: size.width * 0.9)
                .tint(.white)
                Text("FeedBack")
                    .frame(width: size.width * 0.9, alignment: .leading)
                feedback(in: size)
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .padding()
            .onAppear {
                calcHandCV()
                calcFootCV()
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var goodRatio: Double {
        let sum = postureManager.goodPoint + postureManager.notGoodPoint
        return Double(postureManager.goodPoint) / Double(sum)
    }
    
    @State private var goodRatioAnimationValue: Double = 0
    
    private func goodAndNotGoodChart(in size: CGSize) -> some View {
        VStack(spacing: size.height * 0.01) {
            ZStack {
                Pie(endAngle: .degrees(360))
                    .foregroundStyle(.black)
                Pie(endAngle: .degrees(360 * goodRatioAnimationValue))
                    .foregroundStyle(.white)
            }
            HStack {
                Circle()
                    .frame(width: size.width * 0.01, height: size.height * 0.01)
                    .foregroundStyle(.white)
                Text("Good")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(width: size.width * 0.8, alignment: .leading)
            HStack {
                Circle()
                    .frame(width: size.width * 0.01, height: size.height * 0.01)
                    .foregroundStyle(.black)
                Text("Not Good")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(width: size.width * 0.8, alignment: .leading)
        }
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.4)
        .padding(.vertical)
        .background {
            SpecialBrownBackground()
                .frame(width: size.width * 0.9)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: goodRatio * 2.5)) {
                goodRatioAnimationValue = goodRatio
            }
        }
    }
    
    private var postureDatas: [String:Int] {
        var datas = [String:Int]()
        postureManager.recognizedPostures.forEach { key, value in
            datas[key.rawValue] = value
        }
        return datas
    }
    
    private func recognizedPostureChart(in size: CGSize) -> some View {
        Chart(postureDatas.sorted(by: <), id: \.key) { posture in
            BarMark(x: .value("Index", posture.key), y: .value("Value", posture.value))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .fontWeight(.medium)
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.4)
        .padding(.vertical)
        .background {
            SpecialBrownBackground()
                .frame(width: size.width * 0.9)
        }
    }
    
    private func handChart(in size: CGSize) -> some View {
        VStack(spacing: size.height * 0.01) {
            Text("Horizontal").font(.title)
            HStack(spacing: size.width * 0.05) {
                VStack {
                    Text("Left").font(.body)
                    Chart(postureManager.handPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.leftX)
                        )
                    }
                }
                VStack {
                    Text("Right").font(.body)
                    Chart(postureManager.handPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.rightX)
                        )
                    }
                }
            }
            Text("Vertical").font(.title)
            HStack(spacing: size.width * 0.05) {
                VStack {
                    Text("Left").font(.body)
                    Chart(postureManager.handPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.leftY)
                        )
                    }
                }
                VStack {
                    Text("Right").font(.body)
                    Chart(postureManager.handPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.rightY)
                        )
                    }
                }
            }
            analyzedHandDatas(in: size)
        }
        .fontWeight(.light)
        .foregroundStyle(.white)
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.5)
        .padding(.vertical)
        .background {
            SpecialBrownBackground()
                .frame(width: size.width * 0.9)
        }
    }
    
    private func analyzedHandDatas(in size: CGSize) -> some View {
        HStack(spacing: 10) {
            Text("Coefficient of variation:")
            if let handCV = handCV {
                Text("\(String(format: "%.2f", handCV))")
            } else {
                ProgressView().tint(.gray)
            }
        }
        .font(.body)
        .foregroundStyle(.black)
        .padding()
        .background(Color.white.gradient, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func calcHandCV() {
        var rightXDatas = [Float]()
        var rightYDatas = [Float]()
        var leftXDatas = [Float]()
        var leftYDatas = [Float]()
        DispatchQueue.global(qos: .background).async {
            postureManager.handPositions.forEach { position in
                rightXDatas.append(position.rightX)
                rightYDatas.append(position.rightY)
                leftXDatas.append(position.leftX)
                leftYDatas.append(position.leftY)
            }
            if let rightXCV = rightXDatas.coefficientOfVariation(),
               let rightYCV = rightYDatas.coefficientOfVariation(),
               let leftXCV = leftXDatas.coefficientOfVariation(),
               let leftYCV = leftYDatas.coefficientOfVariation() {
                let meanCV = (rightXCV + rightYCV + leftXCV + leftYCV) / Float(4)
                handCV = meanCV
            } else {
                handCV = nil
            }
        }
    }
    
    private func footChart(in size: CGSize) -> some View {
        VStack {
            Text("Horizontal").font(.title)
            HStack(spacing: size.width * 0.05) {
                VStack {
                    Text("Left").font(.body)
                    Chart(postureManager.footPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.leftX)
                        )
                    }
                }
                VStack {
                    Text("Right").font(.body)
                    Chart(postureManager.footPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.rightX)
                        )
                    }
                }
            }
            Text("Vertical").font(.title)
            HStack(spacing: size.width * 0.05) {
                VStack {
                    Text("Left").font(.body)
                    Chart(postureManager.footPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.leftY)
                        )
                    }
                }
                VStack {
                    Text("Right").font(.body)
                    Chart(postureManager.footPositions) { position in
                        LineMark(
                            x: .value("Index", position.id),
                            y: .value("Value", position.rightY)
                        )
                    }
                }
            }
            analyzedFootDatas(in: size)
        }
        .fontWeight(.light)
        .foregroundStyle(.white)
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.5)
        .padding(.vertical)
        .background {
            SpecialBrownBackground()
                .frame(width: size.width * 0.9)
        }
    }
    
    private func analyzedFootDatas(in size: CGSize) -> some View {
        HStack(spacing: 10) {
            Text("Coefficient of variation:")
            if let footCV = footCV {
                Text("\(String(format: "%.2f", footCV))")
            } else {
                ProgressView().tint(.gray)
            }
        }
        .font(.body)
        .foregroundStyle(.black)
        .padding()
        .background(Color.white.gradient, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func calcFootCV() {
        var rightXDatas = [Float]()
        var rightYDatas = [Float]()
        var leftXDatas = [Float]()
        var leftYDatas = [Float]()
        DispatchQueue.global(qos: .background).async {
            postureManager.footPositions.forEach { position in
                rightXDatas.append(position.rightX)
                rightYDatas.append(position.rightY)
                leftXDatas.append(position.leftX)
                leftYDatas.append(position.leftY)
            }
            if let rightXCV = rightXDatas.coefficientOfVariation(),
               let rightYCV = rightYDatas.coefficientOfVariation(),
               let leftXCV = leftXDatas.coefficientOfVariation(),
               let leftYCV = leftYDatas.coefficientOfVariation() {
                let meanCV = (rightXCV + rightYCV + leftXCV + leftYCV) / Float(4)
                footCV = meanCV
            } else {
                footCV = nil
            }
        }
    }
    
    @State private var feedbacks: [String] = []
    @State private var score = ""
    
    @ViewBuilder
    private func feedback(in size: CGSize) -> some View {
        let divider = Divider().background(.black)
        VStack {
            Text("detected problems")
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
            Text("Your score: ")
            if score.isEmpty {
                ProgressView().tint(.gray)
            } else {
                Text(score)
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
                postureFeedback()
                handAndFootFeedback()
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
    
    private func postureFeedback() {
        let sum = postureManager.goodPoint + postureManager.notGoodPoint
        postureManager.recognizedPostures.forEach { key, value in
            if (Double(value) / Double(sum)) > 0.15 {
                feedbacks.append(key.rawValue + "Problem")
            }
        }
    }
    
    private func handAndFootFeedback() {
        guard let handCV = handCV, let footCV = footCV else { return }
        if handCV <= 0.2 {
            feedbacks.append("Moved hands too little")
        } else if handCV >= 0.66 {
            feedbacks.append("Moved hands too much")
        }
        if footCV > 0.36 {
            feedbacks.append("Moved too much during the presentation.")
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
    PostureView()
        .preferredColorScheme(.dark)
}
