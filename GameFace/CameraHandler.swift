//
//  SessionHandler.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import AVFoundation

class CameraHandler : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate, CVFImageProcessorDelegate {
    var session = AVCaptureSession()
    let layer = AVSampleBufferDisplayLayer()
    let sampleQueue = dispatch_queue_create("com.stan.gameface.sampleQueue", DISPATCH_QUEUE_SERIAL)
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var faceDetect = CVFFaceDetect()
    
    var delaunay:NSMutableArray = NSMutableArray()
    
    override init() {
        super.init()
        faceDetect.delegate = self
        delaunay.addObject([1,2])
        delaunay.addObject([3,4])
    }
    
    func openSession() {
        let device = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            .map { $0 as! AVCaptureDevice }
            .filter { $0.position == .Front}
            .first!
        
        let input = try! AVCaptureDeviceInput(device: device)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sampleQueue)
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.sessionPreset = AVCaptureSessionPresetHigh
        session.commitConfiguration()
        
        let settings: [NSObject : AnyObject] = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
        output.videoSettings = settings
        
        session.startRunning()
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        faceDetect.processImageBuffer(pixelBuffer, withMirroring: false)
    }
    
    func mouthVerticePositions(vertices: NSMutableArray!) {
        //parse new mouth location and shape from nsmutable array vertices
        appDelegate.mouth = vertices.map({$0.CGPointValue()})
        
        //testing coordinates from dlib before i pass to gamescene; should be the same as gamescene sprite but more laggy
//        (appDelegate.window?.rootViewController as! GameGallery).useTemporaryLayer()
    }
    
    func imageProcessor(imageProcessor: CVFImageProcessor!, didCreateImage image: UIImage!) {
        (appDelegate.window?.rootViewController as! GameGallery).cameraImage.image = image
    }
    
    func adjustPPI() -> CGFloat {
        return (appDelegate.window?.rootViewController as! GameGallery).debugView.getAdjustedPPI()
    }
    
    func showFaceDetect() -> Bool {
        return (appDelegate.window?.rootViewController as! GameGallery).debugView.getWillShowFaceDetect()
    }
    
    func getDelaunayEdges() -> NSMutableArray! {
        return delaunay
    }
}
