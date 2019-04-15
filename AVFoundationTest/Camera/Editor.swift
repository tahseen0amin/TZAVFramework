//
//  Editor.swift
//  AVFoundationTest
//
//  Created by Tasin Zarkoob on 15/04/2019.
//  Copyright © 2019 Tasin Zarkoob. All rights reserved.
//

import UIKit
import AVFoundation

class WatermarkEditor {
    
    private var sourceAsset: AVAsset!
    private var compostion = AVMutableComposition()
    private var layerComposition : AVVideoComposition!
    
    init(fileUrl: URL) {
        self.sourceAsset = AVURLAsset(url: fileUrl, options: nil)
    }
    
    func export(completion: @escaping (Bool, URL?)->Void){
        self.startComposition()
        
        let path =  NSTemporaryDirectory() + self.fileName()
        let exportedUrl = URL(fileURLWithPath: path)
        guard let exporter = AVAssetExportSession(asset: compostion, presetName: AVAssetExportPresetHighestQuality) else { return }
        
        exporter.videoComposition = self.layerComposition
        exporter.outputURL = exportedUrl
        exporter.outputFileType = .mp4
        
        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                print("Success")
                completion(true, exportedUrl)
                break
                
            default:
                print(exporter.error ?? "Unknown Error")
                completion(false, nil)
            }
        }
        
    }
    
    
    // Start the composition process
    private func startComposition(){
        // add video track to compostion
        self.addVideoTrackToComposition()
        
        // add audio tracks to compostion
        self.addAudioTracksToComposition()
        
        // create watermark layer
        let watermarkLayer = self.createWatermarkLayer()
        
        // create video layer
        let videoLayer = self.createVideoLayer()
        
        // create parentLayer and add other layers to it
        let parentLayer = self.createVideoLayer() // since video layer will be same frame as parent layer
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(watermarkLayer)
        
        // create layer Composition
        self.layerComposition = self.createInstructionForVideoLayer(videoLayer: videoLayer, parentLayer: parentLayer)
        
    }
    
    /// add video track to composition
    private func addVideoTrackToComposition(){
        // get all the video tracks of the source asset
        let tracks = sourceAsset.tracks(withMediaType: .video)
        
        // get the first video track
        let videoTrack = tracks[0]
        let timerange = CMTimeRange(start: .zero, duration: sourceAsset.duration)
        
        // create video track composition track
        guard let compositionVideoTrack = self.compostion.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID()) else {
            print("Cannot add composition track ")
            return
        }
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: .zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
           print(error)
        }
    }
    
    /// add audio tracks to the composition
    private func addAudioTracksToComposition(){
        let audioCompositionTrack = self.compostion.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        
        for audioTrack in self.sourceAsset.tracks(withMediaType: .audio){
            do {
                try audioCompositionTrack?.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: .zero)
            } catch {
                print(error)
            }
        }
    }
    
    private func createWatermarkLayer() -> CALayer {
        let watermarkImage = UIImage(named: "watermark")
        let layer = CALayer()
        layer.contents = watermarkImage?.cgImage
        layer.frame = CGRect(origin: CGPoint(x: 20, y: 20), size: watermarkImage!.size)
        layer.opacity = 0.5
        return layer
    }
    
    private func createVideoLayer() -> CALayer{
        let layer = CALayer()
        let videoTrack = self.sourceAsset.tracks(withMediaType: .video)[0]
        let size = videoTrack.naturalSize
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
    
    private func createInstructionForVideoLayer(videoLayer: CALayer , parentLayer: CALayer) -> AVMutableVideoComposition{
        // get videotrack from composition
        let videoTrack = compostion.tracks(withMediaType: .video)[0]
        
        // create layer instruction
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // create instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: self.compostion.duration)
        
        // add layer instruction to instruction
        instruction.layerInstructions = [layerinstruction]
        
        // create layer composition
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = CMTime(seconds: 1, preferredTimescale: 30)
        layerComposition.renderSize = videoTrack.naturalSize
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        // add instruction to layer composition
        layerComposition.instructions = [instruction]
        return layerComposition
    }
    
    
    
    private func fileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyhhmmss"
        return formatter.string(from: Date()) + ".mp4"
    }
}
