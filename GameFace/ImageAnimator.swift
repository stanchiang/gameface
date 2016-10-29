//
//  ImageAnimator.swift
//  imageToVideo
//
//  Created by Stanley Chiang on 8/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//
//http://stackoverflow.com/a/36290742/1079379

import AVFoundation
import UIKit
import Photos

class ImageAnimator {
    
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
    static let kTimescale: Int32 = 600
    
    let settings: RenderSettings
    let videoWriter: VideoWriter
    var images: [UIImage]!
    
    var frameNum = 0
    
    class func saveToLibrary(videoURL: NSURL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .Authorized else { return }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)
            }) { success, error in
                if !success {
                    print("Could not save video to photo library:", error)
                }
            }
        }
    }
    
    class func removeFileAtURL(fileURL: NSURL) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(fileURL.path!)
        }
        catch _ as NSError {
            // Assume file doesn't exist.
        }
    }
    
    init(renderSettings: RenderSettings, imageArray:[UIImage]) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
        //print("imageArray.count \(imageArray.count)")
        images = imageArray
    }
    
    func render(completion: (videoURL:NSURL)->Void) {
        
        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(settings.outputURL)
        
        videoWriter.start()
//        videoWriter.render(appendPixelBuffers) {
//            ImageAnimator.saveToLibrary(self.settings.outputURL)
//            completion()
//        }

        videoWriter.render(appendPixelBuffers) { 
            completion(videoURL: self.settings.outputURL)
        }
    }
    
    // Replace this logic with your own.
    func loadImages() -> [UIImage] {
        var images = [UIImage]()
        for index in 0...11 {
            let filename = "hand-\(index).png"
            images.append(UIImage(named: filename)!)
        }
        return images
    }
    
    // This is the callback function for VideoWriter.render()
    func appendPixelBuffers(writer: VideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale / settings.fps), ImageAnimator.kTimescale)
        
        while !images.isEmpty {
            
            if writer.isReadyForData == false {
                // Inform writer we have more buffers to write.
                return false
            }
            
            let image = images.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNum))
            let success = videoWriter.addImage(image, withPresentationTime: presentationTime)
            if success == false {
                fatalError("addImage() failed")
            }
            
            frameNum += 1
        }
        
        // Inform writer all buffers have been written.
        return true
    }
    
}
