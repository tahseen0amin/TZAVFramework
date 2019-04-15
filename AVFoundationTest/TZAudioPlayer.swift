//
//  File.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 08/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import AVFoundation

class TZAudioPlayer {
    
    fileprivate let audioSession = AVAudioSession.sharedInstance()
    fileprivate var fileLocationUrl : URL!
    fileprivate var player : AVAudioPlayer!
    
    init(location: String) {
        self.fileLocationUrl = URL(fileURLWithPath: location)
        self.preparePlayer()
    }
    
    fileprivate func preparePlayer(){
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            player = try AVAudioPlayer(contentsOf: fileLocationUrl)
            player?.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    open var isPlaying : Bool {
        return self.player.isPlaying
    }
    
    open var delegate : AVAudioPlayerDelegate? {
        didSet {
            self.player.delegate = self.delegate
        }
    }
    
    open func togglePlaying(){
        if !player.isPlaying {
            player.play()
        } else {
            player.stop()
        }
    }
}

