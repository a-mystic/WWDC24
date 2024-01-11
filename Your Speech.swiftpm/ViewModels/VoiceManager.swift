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
    
    @Published var voiceErrorStatus = VoiceError.notError
    @Published var showVoiceError = false
    
    func requestPermission(changeScreen: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized: 
                changeScreen()
                break
            default: 
                self.voiceErrorStatus = .authError
                self.showVoiceError = true
            }
        }
    }
    
    func startRecording(completion: @escaping (String) -> Void) {
        installTap()
        audioEngine.prepare()
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")), recognizer.isAvailable else {
            voiceErrorStatus = .recognizerError
            showVoiceError = true
            return
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true
        
        recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let error = error {
                print(error)
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
            voiceErrorStatus = .audioSessionError
            showVoiceError = true
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
                            if averageStrength != 0 {
                                self.voiceDatas.append(VoiceModel(id: self.voiceIndex, strength: averageStrength))
                                self.voiceIndex += 1
                            }
                        }
                    }
                }
            }
    }
    
    func stopRecording() {
        do {
            recognitionRequest.endAudio()
            audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            try audioSession.setActive(false)
        } catch {
            voiceErrorStatus = .audioSessionSetActiveError
            showVoiceError = true
        }
    }
    
    enum VoiceError: Error {
        case notError
        case authError
        case recognizerError
        case audioSessionError
        case audioSessionSetActiveError
        
        var errorMessage: String {
            switch self {
            case .authError:
                return "authError"
            case .recognizerError:
                return "recognizerError"
            case .audioSessionError:
                return "audio session error"
            case .audioSessionSetActiveError:
                return "audioSessionSetActiveError"
            default:
                return "something can't recognized error occured"
            }
        }
    }
}
