//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit

extension SKNode {
    class func unarchiveFromFileName(fileName : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class ViewController: UIViewController, testDelegate {
    
    let sessionHandler = SessionHandler()
    var shape: CAShapeLayer!
    
    var testView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionHandler.openSession()
        sessionHandler.delegate = self
        
        setupCameraLayer()
        setupGameLayer()
        
        testView = UIView(frame: view.frame)
        self.view.addSubview(testView)
    }
    
    func setupCameraLayer(){
        let layer = sessionHandler.layer
        layer.frame = self.view.bounds
        layer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI)))
        layer.setAffineTransform(CGAffineTransformScale(layer.affineTransform(), 1, -1))
        self.view.layer.addSublayer(layer)
        
    }
    
    func setupGameLayer() {
        if let scene = GameScene.unarchiveFromFileName("GameScene") as? GameScene {
            // Configure the view.
            
            let skView = SKView(frame: view.frame)
            skView.allowsTransparency = true
            self.view.addSubview(skView as UIView)
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.backgroundColor = UIColor.clearColor()
            skView.presentScene(scene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func drawPolygon(mouth: [CGPoint]) {
        (shape == nil) ? shape = CAShapeLayer() : shape.removeFromSuperlayer()

        let path = UIBezierPath()
        for m in mouth {
            (m == mouth.first!) ? path.moveToPoint(m) : path.addLineToPoint(m)
        }
        
        path.closePath()
        shape.path = path.CGPath
        shape.fillColor = UIColor.greenColor().CGColor

        testView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        testView.transform = CGAffineTransformScale(testView.transform, -1, -1)
        testView.layer.addSublayer(shape)
        
//        shape.fillColor = UIColor.blueColor().CGColor
//        view.layer.addSublayer(shape)

    }

}

