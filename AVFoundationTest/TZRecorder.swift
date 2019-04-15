//
//  TZRecorder.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 08/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import AVFoundation

class TZRecorder {
    
    fileprivate let audioSession = AVAudioSession.sharedInstance()
    fileprivate var fileLocationUrl : URL!
    fileprivate let settings = [AVFormatIDKey: NSNumber.init(value: kAudioFormatAppleLossless),
                                AVSampleRateKey         : NSNumber.init(value: 44100.0),
                                AVNumberOfChannelsKey   : NSNumber.init(value: 1),
                                AVLinearPCMBitDepthKey  : NSNumber.init(value: 16),
                                AVEncoderAudioQualityKey: NSNumber.init(value: AVAudioQuality.high.rawValue)]
    

    fileprivate var recorder : AVAudioRecorder!
    
    init(location: String) {
        self.fileLocationUrl = URL(fileURLWithPath: location)
        self.prepareRecorder()
    }
    
    fileprivate func prepareRecorder(){
        do {
            recorder = try AVAudioRecorder(url: self.fileLocationUrl, settings: settings)
            recorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    open var isRecording : Bool {
        return self.recorder.isRecording
    }
    
    open func toggleRecording(){
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            
            if !recorder.isRecording {
                try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
                recorder.record()
            } else {
                recorder.stop()
                try audioSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
                if self.verifyFileExists() {
                    debugPrint("Recorded successfully")
                } else {
                    debugPrint("There was a problem recording")
                }
            }
        } catch {
            print(error)
        }
    }
    
    fileprivate func verifyFileExists() -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: self.fileLocationUrl.absoluteString)
    }
}
