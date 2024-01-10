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
                .onAppear {
                    print(postureManager.handPositions)
                }
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
        } stopAction: {
            withAnimation {
                playStatus = .finish
            }
        }
    }
    
    @State private var handCV = ""
    @State private var footCV = ""
    
    private func result(in size: CGSize) -> some View {
        ScrollView {
            VStack(spacing: size.height * 0.05) {
                Text("good/bad").font(.largeTitle)
                goodAndNotGoodChart(in: size)
                Text("recognized Postures").font(.largeTitle)
                recognizedPostureChart(in: size)
                Text("hand/foot moves").font(.largeTitle)
                leftAndRightMoveChart(in: size)
                feedBack(in: size)
            }
            .padding()
            .onAppear {
                calcHandCV()
                calcFootCV()
            }
        }
    }
    
    private var goodRatio: Double {
        let sum = postureManager.goodPoint + postureManager.notGoodPoint
        return Double(postureManager.goodPoint) / Double(sum)
    }
    
    private func goodAndNotGoodChart(in size: CGSize) -> some View {
        ZStack {
            Pie(endAngle: .degrees(360))
                .foregroundStyle(.black)
            Pie(endAngle: .degrees(360 * goodRatio))
                .foregroundStyle(.white)
        }
        .padding()
        .frame(width: size.width * 0.9, height: 300)
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
        .padding()
        .frame(width: size.width * 0.9, height: 300)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.brown.gradient)
                .frame(width: size.width * 0.9)
        }
    }
    
    private func leftAndRightMoveChart(in size: CGSize) -> some View {
        HStack(spacing: 40) {
            Chart(postureManager.handPositions) { position in
                LineMark(
                    x: .value("Index", position.id),
                    y: .value("Value", (position.rightX + position.rightY) / 2),
                    series: .value("", "Right")
                )
                .foregroundStyle(.white)
                LineMark(
                    x: .value("Index", position.id),
                    y: .value("Value", (position.leftX + position.leftY) / 2),
                    series: .value("", "Left")
                )
                .foregroundStyle(.black)
            }
            Chart(postureManager.footPositions) { position in
                LineMark(
                    x: .value("Index", position.id),
                    y: .value("Value", (position.rightX + position.rightY) / 2),
                    series: .value("", "Right")
                )
                .foregroundStyle(.white)
                LineMark(
                    x: .value("Index", position.id),
                    y: .value("Value", (position.leftX + position.leftY) / 2),
                    series: .value("", "Left")
                )
                .foregroundStyle(.black)
            }
        }
        .padding()
        .frame(width: size.width * 0.9, height: 300)
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
                let meanCV = (rightXCV + rightYCV + leftXCV + leftYCV) / 4
                handCV = "\(meanCV)"
            } else {
                handCV = "error can't calculate"
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
                let meanCV = (rightXCV + rightYCV + leftXCV + leftYCV) / 4
                footCV = "\(meanCV)"
            } else {
                footCV = "error can't calculate"
            }
        }
    }
    
    private func feedBack(in size: CGSize) -> some View {
        VStack {
            Text("the result is..")
            HStack {
                Text("your hand cv: ")
                if handCV.isEmpty {
                    ProgressView().foregroundStyle(.gray)
                }
                Text(handCV)
            }
            HStack {
                Text("your foot cv: ")
                if footCV.isEmpty {
                    ProgressView().foregroundStyle(.gray)
                }
                Text(footCV)
            }
        }
        .foregroundStyle(.black)
        .font(.body)
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
    PostureView()
        .preferredColorScheme(.dark)
}
