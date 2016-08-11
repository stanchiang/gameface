//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import SpriteKit


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
        
//        testView = UIView(frame: view.frame)
//        self.view.addSubview(testView)
    }
    
    func setupCameraLayer(){
        let layer = sessionHandler.layer
        layer.frame = self.view.bounds
        layer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI)))
        layer.setAffineTransform(CGAffineTransformScale(layer.affineTransform(), 1, -1))
        self.view.layer.addSublayer(layer)
        
    }
    
    func setupGameLayer() {
//        if let scene = GameScene.unarchiveFromFileName("GameScene") as? GameScene {
            // Configure the view.
            
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
            skView.presentScene(scene)
//        }
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

