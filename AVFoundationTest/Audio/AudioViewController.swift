//
//  AudioViewController.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 08/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    
    private var myrecorder : TZRecorder!
    private var audioPlayer : TZAudioPlayer!
    
    open var location : String = NSTemporaryDirectory().appending("newrecording.m4a") {
        didSet {
            self.configureRecorder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureRecorder()
    }
    
    fileprivate func configureRecorder(){
        myrecorder = TZRecorder(location: self.location)
    }
    
    fileprivate func configureAudioPlayer(){
        self.audioPlayer = TZAudioPlayer(location: self.location)
        self.audioPlayer.delegate = self
    }
    
    fileprivate func toggleUI(){
        if myrecorder.isRecording {
            recordButton.setTitle("Stop Recording", for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
    fileprivate func togglePlayerUI(){
        if self.audioPlayer.isPlaying {
            playButton.setTitle("Pause", for: .normal)
        } else {
            playButton.setTitle("Play", for: .normal)
        }
    }

    //MARK: - IBActions
    @IBAction private func didPressRecordButton(sender: UIButton){
        myrecorder.toggleRecording()
        if !myrecorder.isRecording {
            if self.verifyFileExists() {
                // configure player
               self.configureAudioPlayer()
                playButton.isHidden = false
            }
        } else {
            playButton.isHidden = true
        }
        self.toggleUI()
        
    }
    
    @IBAction fileprivate func playRecordingPressed(sender: UIButton){
        self.audioPlayer.togglePlaying()
        self.togglePlayerUI()
    }
    //MARK: -
    
    func verifyFileExists() -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: self.location)
    }
    
}

extension AudioViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.togglePlayerUI()
    }
}


