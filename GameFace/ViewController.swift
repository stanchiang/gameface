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
    
    var gameView:UIView!
    var managerView:UIView!
    
    var scene:GameScene!
    var manager:GameManager!
    
    var cameraImage:UIImageView!
    
    override func viewDidLoad() {
        sessionHandler.openSession()
        self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.view.transform = CGAffineTransformScale(self.view.transform, 1, -1)
        
        setupCameraImage()
        loadGame()
        startRecording()
        
    }

    func setupCameraImage(){
        cameraImage = UIImageView()
        cameraImage.frame = self.view.frame
        self.view.addSubview(cameraImage)
    }
    
    func setupGameLayer() {
        gameView = UIView(frame: self.view.frame)
        self.view.addSubview(gameView)
        
        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true

        gameView.addSubview(skView as UIView)

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
        print("loading post game modal")
        stopRecording()
        
    }

    func startRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        recorder.startRecordingWithMicrophoneEnabled(true) { [unowned self] (error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                print("called")
                self.manager.instructions.text = "Open Mouth to Start Game"
            }
        }
    }

    func loadGame(){
        self.setupGameLayer()
        self.setupGameManager()
        self.scene.sceneDelegate = self.manager
        self.manager.managerDelegate = self.scene
        self.manager.uikitDelegate = self

    }
    
    func stopRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        print("initiating stop recording")
        recorder.stopRecordingWithHandler { [unowned self] (RPPreviewViewController, error) in
            print("in completion handler")
            if let previewView = RPPreviewViewController {
                print("will transition to gameplay video")
                previewView.previewControllerDelegate = self
                self.presentViewController(previewView, animated: true, completion: nil)
                self.sessionHandler.session.stopRunning()
            }
        }
    }

    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        dismissViewControllerAnimated(true) { [unowned self] in
//            self.sessionHandler.session.startRunning()
//            (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .preGame
////            self.manager.timer.xScale = 1
//            self.managerView.removeFromSuperview()
//            self.gameView.removeFromSuperview()
//            self.view.sendSubviewToBack(self.cameraImage)
//            self.startRecording()
            (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = ViewController()
        }
    }

}
