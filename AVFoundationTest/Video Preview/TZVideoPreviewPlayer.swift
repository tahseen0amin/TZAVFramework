//
//  TZVideoPreviewPlayer.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 10/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class TZVideoPreviewPlayer: UIViewController {
    
    static let assetKeysRequiredToPlay = ["playable","hasProtectedContent"]
    
    @IBOutlet private weak var videoPreview: PlayerView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    
    @objc dynamic private let player = AVPlayer()
    
    open var fileLocation : URL! {
        didSet {
            // try to get asset from the file location
            self.asset = AVAsset(url: self.fileLocation)
        }
    }
    
    fileprivate var asset: AVAsset? {
        didSet {
            guard let newAsset = asset else {return}
            // load this new asset
            self.loadAsset(asset: newAsset)
        }
    }
    
    private var playerItem: AVPlayerItem! {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
            player.actionAtItemEnd = .none
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver(self, forKeyPath: "player.currentItem.status", options: .new, context: nil)
        addObserver(self, forKeyPath: "player.rate", options: [.new, .initial], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerReachedEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.videoPreview.playerLayer.player = player
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObserver(self, forKeyPath: "player.currentItem.status", context: nil)
        removeObserver(self, forKeyPath: "player.rate", context: nil)
    }
    
    @IBAction private func saveButtonPressed(){
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: self.fileLocation)
        }) { (success, error) in
            //
            if success {
                print("Success")
                
            } else {
                print(error!)
            }
        }
    }
    
    @IBAction private func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    

    private func loadAsset(asset: AVAsset){
        
        asset.loadValuesAsynchronously(forKeys: TZVideoPreviewPlayer.assetKeysRequiredToPlay) {
            for key in TZVideoPreviewPlayer.assetKeysRequiredToPlay {
                if !asset.isPlayable || asset.hasProtectedContent {
                    print("Cannot play the video")
                    return
                }
                var error: NSError?
                if asset.statusOfValue(forKey: key, error: &error) == .failed {
                    print("Failed to load the data : \(String(describing: error))")
                    return
                }
            }
            
            DispatchQueue.main.async {
                self.playerItem = AVPlayerItem(asset: asset)
            }
        }
    }
    
    @objc func playerReachedEnd(notification:NSNotification) {
        //To restart video
        self.asset = AVURLAsset(url: self.fileLocation!)
        self.player.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "player.currentItem.status" {
            self.player.play()
        }
    }
}
