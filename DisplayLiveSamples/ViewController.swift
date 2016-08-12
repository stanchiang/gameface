//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    let sessionHandler = SessionHandler()
    var shape: CAShapeLayer!
    var extralayer:CALayer = CALayer()
    var mouth:[CGPoint]!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        sessionHandler.openSession()
        
        self.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.view.transform = CGAffineTransformScale(self.view.transform, 1, -1)
        
        setupCameraLayer()
        setupGameLayer()
        
    }
    
    func setupCameraLayer(){
        let layer = sessionHandler.layer
        layer.frame = self.view.bounds
        self.view.layer.addSublayer(layer)
        
    }
    
    func setupGameLayer() {
        let skView = SKView(frame: view.frame)
        skView.allowsTransparency = true
        
        self.view.addSubview(skView as UIView)
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        let scene = GameScene(size: self.view.frame.size)
        scene.scaleMode = .AspectFill
        scene.backgroundColor = UIColor.clearColor()
        scene.yScale = -1.0
        skView.presentScene(scene)
    }
    
    func useTemporaryLayer() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
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
}

