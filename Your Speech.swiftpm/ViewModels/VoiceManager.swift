//
//  File.swift
//  
//
//  Created by a mystic on 12/26/23.
//

import Foundation
import Speech

class VoiceManager: ObservableObject {
    @Published private(set) var voiceDatas = [VoiceModel]()

    private var audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode { audioEngine.inputNode }
    private var audioSession = AVAudioSession()
    private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var voiceIndex: UInt64 = 0
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized: break
            default: print("Auth error")
            }
        }
    }
    
    func startRecording(completion: @escaping (String) -> Void) {
        installTap()
        audioEngine.prepare()
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")), recognizer.isAvailable else { return }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true
        
        recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if error != nil {
                print("Error")
                return
            }
            guard let result = result else { return }
            completion(result.bestTranscription.formattedString)
        }
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioEngine.start()
        } catch {
            print(error)
        }
    }
    
    private func installTap() {
        let recordingFormat = inputNode.outputFormat(forBus: 0)
            self.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                DispatchQueue.global(qos: .background).async {
                    self.recognitionRequest.append(buffer)
                    if let channelData = buffer.floatChannelData?[0] {
                        let bufferLength = Int(buffer.frameLength)
                        var sumOfStrength: Float = 0
                        for i in 0..<bufferLength {
                            sumOfStrength += abs(channelData[i])
                        }
                        let averageStrength = sumOfStrength / Float(bufferLength)
                        DispatchQueue.main.async {
                            self.voiceDatas.append(VoiceModel(strength: averageStrength, id: self.voiceIndex))
                            self.voiceIndex += 1
                        }
                    }
                }
            }
    }
    
    func stopRecording() {
        recognitionRequest.endAudio()
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        try? audioSession.setActive(false)
    }
}
