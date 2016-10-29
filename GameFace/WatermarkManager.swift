//
//  WatermarkManager.swift
//  GameFace
//
//  Created by Stanley Chiang on 10/28/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//
//http://stackoverflow.com/a/32813927/1079379

import UIKit
import AssetsLibrary
import AVFoundation

enum WatermarkPosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case Default
}

class WatermarkManager: NSObject {
    
    func watermark(video videoAsset:AVAsset, watermarkText text : String, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
        self.watermark(video: videoAsset, watermarkText: text, imageName: nil, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
            completion!(status: status, session: session, outputURL: outputURL)
        }
    }
    
    func watermark(video videoAsset:AVAsset, imageName name : String, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
        self.watermark(video: videoAsset, watermarkText: nil, imageName: name, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
            completion!(status: status, session: session, outputURL: outputURL)
        }
    }
    
    private func watermark(video videoAsset:AVAsset, watermarkText text : String!, imageName name : String!, saveToLibrary flag : Bool, watermarkPosition position : WatermarkPosition, completion : ((status : AVAssetExportSessionStatus!, session: AVAssetExportSession!, outputURL : NSURL!) -> ())?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
            let mixComposition = AVMutableComposition()
            
            // 2 - Create video tracks
            let compositionVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] 
            try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: clipVideoTrack, atTime: kCMTimeZero)
            clipVideoTrack.preferredTransform
            
            // Video size
            let videoSize = clipVideoTrack.naturalSize
            
            // sorts the layer in proper order and add title layer
            let parentLayer = CALayer()
            let videoLayer = CALayer()
            parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
            videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
            parentLayer.addSublayer(videoLayer)
            
            if text != nil {
                // Adding watermark text
                let titleLayer = CATextLayer()
                titleLayer.backgroundColor = UIColor.redColor().CGColor
                titleLayer.string = text
                titleLayer.font = "Helvetica"
                titleLayer.fontSize = 15
                titleLayer.alignmentMode = kCAAlignmentCenter
                titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height)
                parentLayer.addSublayer(titleLayer)
                
                print("\(videoSize.width)")
                print("\(videoSize.height)")
            } else if name != nil {
                // Adding image
                let watermarkImage = UIImage(named: name)
                let imageLayer = CALayer()
                imageLayer.contents = watermarkImage?.CGImage
                
                var xPosition : CGFloat = 0.0
                var yPosition : CGFloat = 0.0
                let imageSize : CGFloat = 57.0
                
                switch (position) {
                case .TopLeft:
                    xPosition = 0
                    yPosition = 0
                    break
                case .TopRight:
                    xPosition = videoSize.width - imageSize
                    yPosition = 0
                    break
                case .BottomLeft:
                    xPosition = 0
                    yPosition = videoSize.height - imageSize
                    break
                case .BottomRight, .Default:
                    xPosition = videoSize.width - imageSize
                    yPosition = videoSize.height - imageSize
                    break
                default:
                    break
                }
                
                print("xPosition = \(xPosition)")
                print("yPosition = \(yPosition)")
                
                imageLayer.frame = CGRectMake(xPosition, yPosition, imageSize, imageSize)
                imageLayer.opacity = 0.65
                parentLayer.addSublayer(imageLayer)
            }
            
            let videoComp = AVMutableVideoComposition()
            videoComp.renderSize = videoSize
            videoComp.frameDuration = CMTimeMake(1, 30)
            videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
            
            /// instruction
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
            _ = mixComposition.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
            
            let layerInstruction = self.videoCompositionInstructionForTrack(compositionVideoTrack, asset: videoAsset)
            
            //var layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            
            instruction.layerInstructions = [layerInstruction]
            videoComp.instructions = [instruction]
            
            // 4 - Get path
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .LongStyle
            dateFormatter.timeStyle = .ShortStyle
            let date = dateFormatter.stringFromDate(NSDate())
            let savePath = (documentDirectory as NSString).stringByAppendingPathComponent("watermarkVideo-\(date).mov")
            let url = NSURL(fileURLWithPath: savePath)
            
            // 5 - Create Exporter
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exporter!.outputURL = url
            exporter!.outputFileType = AVFileTypeMPEG4
            exporter!.shouldOptimizeForNetworkUse = true
            
            
            exporter!.videoComposition = videoComp
            
            // 6 - Perform the Export
            exporter!.exportAsynchronouslyWithCompletionHandler() {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if exporter!.status == AVAssetExportSessionStatus.Completed {
                        let outputURL = exporter!.outputURL
                        if flag {
                            // Save to library
                            let library = ALAssetsLibrary()
                            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL) {
                                library.writeVideoAtPathToSavedPhotosAlbum(outputURL,
                                                                           completionBlock: { (assetURL:NSURL!, error:NSError!) -> Void in
                                                                            completion!(status: AVAssetExportSessionStatus.Completed, session: exporter, outputURL: outputURL)
                                })
                            }
                        } else {
                            // Dont svae to library
                            completion!(status: AVAssetExportSessionStatus.Completed, session: exporter, outputURL: outputURL)
                        }
                        
                    } else {
                        // Error
                        completion!(status: exporter!.status, session: exporter, outputURL: nil)
                    }
                })
            }
        })
    }
    
    
    private func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
        }
        return (assetOrientation, isPortrait)
    }
    
    private func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] 
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                                     atTime: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
}
