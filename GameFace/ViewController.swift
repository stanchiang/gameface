//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import ReplayKit

class ViewController: UIViewController, RPPreviewViewControllerDelegate, UIKitDelegate {
    let sessionHandler = SessionHandler()
    var shape: CAShapeLayer!
    
    var mouth:[CGPoint]!
    
    var managerView:UIView!
    
    var scene:GameScene!
    var manager:GameManager!
    
    var cameraImage:UIImageView!
    
    override func viewDidLoad() {
        sessionHandler.openSession()
        self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.view.transform = CGAffineTransformScale(self.view.transform, 1, -1)
        
        //        setupCameraLayer()
        setupCameraImage()
        
        setupGameLayer()
        setupGameManager()
        
        scene.sceneDelegate = manager
        manager.managerDelegate = scene
        manager.uikitDelegate = self
        
        startRecording()
    }

    func setupCameraImage(){
        cameraImage = UIImageView()
        cameraImage.frame = self.view.frame
        self.view.addSubview(cameraImage)
    }
    
    func setupGameLayer() {

        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true

        self.view.addSubview(skView as UIView)

//        skView.showsFPS = true
//        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene = GameScene(size: self.view.frame.size)
        scene.scaleMode = .AspectFill
        scene.backgroundColor = UIColor.clearColor()
        skView.presentScene(scene)
    }
    
    func setupGameManager(){
        
        managerView = UIView(frame: self.view.frame)
        managerView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        managerView.transform = CGAffineTransformScale(managerView.transform, 1, -1)

        self.view.addSubview(managerView)
        
        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true
        
        managerView.addSubview(skView as UIView)
        skView.ignoresSiblingOrder = true
        
        manager = GameManager(size: self.view.frame.size)
        manager.scaleMode = .AspectFill
        manager.backgroundColor = UIColor.clearColor()
        skView.presentScene(manager)
    }
    
    func useTemporaryLayer() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [unowned self] in
            self.mouth = (UIApplication.sharedApplication().delegate as! AppDelegate).mouth
            
            (self.shape == nil) ? self.shape = CAShapeLayer() : self.shape.removeFromSuperlayer()
            
            let path = UIBezierPath()
            for m in self.mouth {
                (m == self.mouth.first!) ? path.moveToPoint(m) : path.addLineToPoint(m)
            }
            
            path.closePath()
            self.shape.path = path.CGPath
            self.shape.fillColor = UIColor.greenColor().CGColor
            
            dispatch_async(dispatch_get_main_queue()) {
                self.view.layer.addSublayer(self.shape)
            }
        })
    }
    
    func loadPostGameModal() {
        stopRecording()
        print("loading post game modal")
    }

    func startRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        recorder.startRecordingWithMicrophoneEnabled(true) {(error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                print("called")
            }
        }
    }

    func stopRecording() {
        sessionHandler.session.stopRunning()
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { [unowned self] (RPPreviewViewController, error) in
            if let previewView = RPPreviewViewController {
                previewView.previewControllerDelegate = self
                self.presentViewController(previewView, animated: true, completion: nil)
            }
        }
    }

    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        dismissViewControllerAnimated(true) { [unowned self] in
            self.sessionHandler.session.startRunning()
        }
    }
    
    func stopRecordingHandler() {
        stopRecording()
    }
}
