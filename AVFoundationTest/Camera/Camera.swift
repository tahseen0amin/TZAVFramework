//
//  Camera.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 15/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import UIKit
import AVFoundation

class Camera {
    
    var maxrecordTime : Double = 0
    var delegate : AVCaptureFileOutputRecordingDelegate!
    var outputFileLocation: URL!
    
    // private variables
    private var previewLayer : AVCaptureVideoPreviewLayer?
    private var captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice!
    private var movieFileOutput = AVCaptureMovieFileOutput()
    
    open var isCameraRecording : Bool {
        return self.movieFileOutput.isRecording
    }
    
    init() {
        // set the capture session preset to high
        self.captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // get the discovery session
        guard let discovery = self.getCaptureDeviceDiscoverySession() else {return}
        
        // get the back camera capture device from the discovery session
        var tempDevice : AVCaptureDevice?
        for device in discovery.devices {
            if device.hasMediaType(.video) && device.position == .back {
                tempDevice = device
            }
        }
        
        // set the back camera as the capture device
        guard let device = tempDevice else {return}
        self.captureDevice = device
        
        do {
            // add video input to the capture session
            try self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice))
            
            // add audio input to the capture session
            if let audioInput = AVCaptureDevice.default(for: .audio) {
                try self.captureSession.addInput(AVCaptureDeviceInput(device: audioInput))
            }
        } catch {
            print(error)
        }
        
    }
    
    /// Start Camera Capture Session
    func startCameraCaptureSession(inParentView parent: UIView){
        // create a preview layer from the capture session
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        // add the preview layer to the parent view
        parent.layer.addSublayer(self.previewLayer!)
        
        // set the frame of the preview layer
        self.previewLayer?.frame = parent.frame
        
        // set the video orientation
        self.setVideoOrientation(parentView: parent)
        
        // add the output of the capture session to the file location
        self.captureSession.addOutput(self.movieFileOutput)
        
        // start the capture session
        self.captureSession.startRunning()
    }
    
    /// Set the video orientation and set the frame
    func setVideoOrientation(parentView: UIView) {
        if let connection = self.previewLayer?.connection {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = self.videoOrientation()
                self.previewLayer?.frame = parentView.bounds
            }
        }
    }
    
    /// start the recording
    func toggleRecording(){
        if isCameraRecording {
            self.movieFileOutput.stopRecording()
        } else {
            // set the orientation of file output
            self.movieFileOutput.connection(with: .video)?.videoOrientation = self.videoOrientation()
            
            // set the maximum record time if needed
            self.movieFileOutput.maxRecordedDuration = self.maximumRecordingTime()
            
            // start recording to file location
            self.movieFileOutput.startRecording(to: self.outputFileLocation, recordingDelegate: self.delegate)
        }
    }
    
    // toggle between front and back camera
    func toggleCamera(){
        // we have lock the configuration
        self.captureSession.beginConfiguration()
        
        // get the existing video input
        var existingCameraInput : AVCaptureDeviceInput!
        for input in self.captureSession.inputs {
            let videoInput = (input as! AVCaptureDeviceInput)
            if videoInput.device.hasMediaType(.video) {
                existingCameraInput = videoInput
            }
        }
        
        // get the new camera based on the existing camera
        var newCameraDevice: AVCaptureDevice!
        if existingCameraInput.device.position == .back {
            // get the front camera
            newCameraDevice = self.getCameraWithPosition(position: .front)
        } else {
            // get the back camera
            newCameraDevice = self.getCameraWithPosition(position: .back)
        }
        
        // create the new camera input
        var newCameraInput: AVCaptureDeviceInput!
        do {
            newCameraInput = try AVCaptureDeviceInput(device: newCameraDevice)
        } catch {
            print("Couldn't create the new camera input : \(error)")
        }
        
        // remove the existing camera input
        self.captureSession.removeInput(existingCameraInput)
        
        // add the new camera input
        self.captureSession.addInput(newCameraInput)
        // release the lock
        self.captureSession.commitConfiguration()
    }
}

// MARK : - Helpers methods
extension Camera {
    
    /// Get the Discovery Session using builtInWideAngleCamera Type
    private func getCaptureDeviceDiscoverySession() -> AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    }
    
    /// Get AVCaptureDevice on position (front or back)
    private func getCameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in discovery.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    /// Get Video Orientation based on the current device orientation
    private func videoOrientation() -> AVCaptureVideoOrientation {
        var videoOrientation:AVCaptureVideoOrientation!
        
        let orientation:UIDeviceOrientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            videoOrientation = .portrait
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        default:
            videoOrientation = .portrait
        }
        
        return videoOrientation
    }
    
    /// set the maximum recording time
    private func maximumRecordingTime() -> CMTime {
        let preferredTimeScale : Int32 = 1
        if self.maxrecordTime > 0 {
            return CMTime(seconds: self.maxrecordTime, preferredTimescale: preferredTimeScale)
        } else {
            return CMTime.invalid
        }
    }
}
