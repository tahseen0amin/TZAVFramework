//
//  CameraViewController.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 09/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController {
    
    @IBOutlet fileprivate weak var recordButton : UIButton!
    @IBOutlet fileprivate weak var toggleButton : UIButton!
    @IBOutlet fileprivate weak var preview : UIView!
    
    private func videoFileLocation() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory().appending("videoFile.mov"))
    }
    
    // variables
    private var camera : Camera!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.camera = Camera()
        self.camera.delegate = self
        self.camera.outputFileLocation = self.videoFileLocation()
        self.camera.startCameraCaptureSession(inParentView: self.preview)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // handle orientation
        self.camera.setVideoOrientation(parentView: self.view)
    }
    
    // MARK : - IBACTIONS
    @IBAction private func recordButtonPressed(){
        if self.camera.isCameraRecording {
            self.recordButton.setImage(UIImage(named: "record"), for: .normal)
        } else {
            self.recordButton.setImage(UIImage(named: "stop"), for: .normal)
        }
        self.camera.toggleRecording()
    }
    
    /// change the camera input from back to front camera or vice versa
    @IBAction private func toggleButtonPressed(){
        self.camera.toggleCamera()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Finished Recording. Output file : \(outputFileURL)")
        self.recordButton.setImage(UIImage(named: "record"), for: .normal)
        
        let preview = TZVideoPreviewPlayer()
        preview.fileLocation = outputFileURL
        self.present(preview, animated: true, completion: nil)
    }
    
    
}
