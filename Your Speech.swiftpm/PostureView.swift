//
//  PostureView.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import SwiftUI
import Charts

struct PostureView: View {
    @StateObject private var postureManager = PostureManager.shared
        
    var body: some View {
        GeometryReader { geometry in
            VStack {
                contents(in: geometry.size)
                playButton
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    @ViewBuilder
    private func contents(in size: CGSize) -> some View {
        switch playStatus {
        case .notPlay:
            VStack {
                Text("This view is a..")
                placeHolder(in: size)
            }
        case .play:
            recognizePosture(in: size)
        case .finish:
            result(in: size)
        }
    }
    
    private func placeHolder(in size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(Color.white.gradient)
                .frame(width: size.width * 0.9, height: size.height * 0.77)
                .padding()
            VStack {
                Image(systemName: "figure.arms.open")
                    .imageScale(.large)
                    .font(.system(size: size.width * 0.3))
                Text("Please tap start!!")
                    .font(.largeTitle)
            }
            .foregroundStyle(.black)
            loading
        }
    }
    
    private func recognizePosture(in size: CGSize) -> some View {
        ZStack(alignment: .bottom) {
            PostureRecognitionViewRefer()
                .frame(width: size.width * 0.9, height: size.height * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(postureManager.currentPosture)
                .font(.title)
                .padding()
                .foregroundStyle(.white)
//                .opacity(postureManager.currentPostureMode == .ready ? 1 : 0)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.ultraThinMaterial)
                }
        }
        .overlay {
            countdownAnimation(in: size)
        }
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
    
    @State private var playStatus = PlayButton.PlayStatus.notPlay
    
    private var playButton: some View {
        PlayButton(playStatus: $playStatus) {
            DispatchQueue.global(qos: .background).async {
                isLoading = true
                withAnimation {
                    playStatus = .play
                    isLoading = false
                }
            }
            testModeFunc()
        } stopAction: {
            withAnimation {
                playStatus = .finish
            }
        }
    }
    
    private func testModeFunc() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 10) {
            withAnimation {
                playStatus = .finish
            }
        }
    }
    
    @State private var handCV: Float?
    @State private var footCV: Float?
    
    private func result(in size: CGSize) -> some View {
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
                feedBack(in: size)
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
    
    private func goodAndNotGoodChart(in size: CGSize) -> some View {
        VStack(spacing: size.height * 0.01) {
            ZStack {
                Pie(endAngle: .degrees(360))
                    .foregroundStyle(.black)
                Pie(endAngle: .degrees(360 * goodRatio))
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
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.brown.gradient)
                .frame(width: size.width * 0.9)
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
        }
        .fontWeight(.medium)
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.4)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.brown.gradient)
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
            HStack(spacing: 10) {
                Text("your hand cv:")
                if let handCV = handCV {
                    Text("\(handCV)")
                } else {
                    ProgressView().tint(.black)
                }
            }
        }
        .fontWeight(.light)
        .foregroundStyle(.white)
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.4)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.brown.gradient)
                .frame(width: size.width * 0.9)
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
            HStack(spacing: 10) {
                Text("your hand cv:")
                if let footCV = footCV {
                    Text("\(footCV)")
                } else {
                    ProgressView().tint(.black)
                }
            }
        }
        .fontWeight(.light)
        .foregroundStyle(.white)
        .padding()
        .frame(width: size.width * 0.9, height: size.height * 0.4)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.brown.gradient)
                .frame(width: size.width * 0.9)
        }
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
    
    private func feedBack(in size: CGSize) -> some View {
        VStack {
            Text("detected problems")
            if feedbacks.isEmpty {
                ProgressView()
                    .tint(.black)
                    .scaleEffect(2)
            } else {
                ForEach(feedbacks.indices, id: \.self) { index in
                    Text(feedbacks[index])
                }
            }
            Text("Your final score...")
        }
        .foregroundStyle(.black)
        .font(.body)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white.gradient)
                .frame(width: size.width * 0.9)
        }
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                postureFeedback()
                handAndFootFeedback()
            }
        }
    }
    
    private func postureFeedback() {
        let sum = postureManager.recognizedPostures.values.reduce(0, +)
        postureManager.recognizedPostures.forEach { key, value in
            if (Double(value) / Double(sum)) > 0.15 {
                feedbacks.append(key.rawValue + "Problem")
            }
        }
    }
    
    private func handAndFootFeedback() {
        guard let handCV = handCV, let footCV = footCV else { return }
        if handCV > 0.65 {
            feedbacks.append("Moving too much hand")
        } else if handCV < 0.15 {
            feedbacks.append("Moving too less hand")
        }
        if footCV > 0.65 {
            feedbacks.append("move too much when giving a presentation.")
        }
    }
    
    @State private var isLoading = false

    @ViewBuilder
    private var loading: some View {
        if isLoading {
            ProgressView()
                .tint(.black)
                .scaleEffect(2)
        }
    }
}

#Preview {
    PostureView()
        .preferredColorScheme(.dark)
}
