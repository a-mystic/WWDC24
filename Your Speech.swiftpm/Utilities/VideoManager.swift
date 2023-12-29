//
//  File.swift
//  
//
//  Created by a mystic on 12/27/23.
//

import AVKit

final class VideoManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let videoDevice = AVCaptureDevice.default(for: .video)

    var videoLayer: AVCaptureVideoPreviewLayer {
        AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    private var videoOutput: AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        return output
    }
    
    override init() {
        super.init()
        guard let videoDevice = videoDevice, let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        captureSession.addInput(videoInput)
        captureSession.addOutput(videoOutput)
    }
    
    func startVideoCapturing() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopVideoCapturing() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }
    
    func requestPermission(completion: @escaping (_ accessGranted: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { (accessGranted) in
            completion(accessGranted)
        }
    }
}


