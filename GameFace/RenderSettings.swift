//
//  RenderSettings.swift
//  imageToVideo
//
//  Created by Stanley Chiang on 8/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//
//http://stackoverflow.com/a/36290742/1079379

import UIKit
import AVFoundation

struct RenderSettings {
    
    var width: CGFloat = UIScreen.mainScreen().bounds.width //720
    var height: CGFloat = UIScreen.mainScreen().bounds.height //1280
    var fps: Int32 = 30
    var avCodecKey = AVVideoCodecH264
    var videoFilename = "render\(NSDate().timeIntervalSince1970)"
    var videoFilenameExt = "mp4"
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var outputURL: NSURL {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        let fileManager = NSFileManager.defaultManager()
        if let tmpDirURL = try? fileManager.URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true) {
            return tmpDirURL.URLByAppendingPathComponent(videoFilename)!.URLByAppendingPathExtension(videoFilenameExt)!
        }
        fatalError("URLForDirectory() failed")
    }
}

