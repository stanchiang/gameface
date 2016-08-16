//
//  GameScene.swift
//  Space Race
//
//  Created by Jason Eng on 9/13/15.
//  Copyright (c) 2015 EngJason. All rights reserved.
//

import SpriteKit

protocol GameSceneDelegate: class {
    func updateScore(points:Int)
    func hideInstructions()
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameManagerDelegate {
    
    weak var sceneDelegate:GameSceneDelegate?
    
    var polygonNode:SKSpriteNode!
    var polygon:SKShapeNode!

    var pauseButton:SKSpriteNode!

    var possibleEnemies = ["ball", "ball", "hammer"]
    var gameTimer: NSTimer!
    var gameOver = false
    var gameStarted = false
    
    override func didMoveToView(view: SKView) {
        setupInterface()
        
    }
    
    func setupInterface(){        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

    }
    
    func setupNew() {
        let start = CGPointMake(RandomCGFloat(0, max: self.frame.width), self.frame.height)
        let end = CGPointMake(RandomCGFloat(self.frame.width * 1/4, max: self.frame.width * 3/4), 0)
        
        createNew(view!, fromPoint: start, toPoint: end)
    }
    
    func createNew(view : SKView, fromPoint start : CGPoint, toPoint end: CGPoint) {
        //1 is good 2 is bad
//        let rand = RandomInt(1, max: 2)
        let rand = 1
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[rand])
        let path = arcBetweenPoints(view, fromPoint: start, toPoint: end)
        let followArc = SKAction.followPath(path, asOffset: false, orientToPath: true, duration: 1)
        
        sprite.position = start
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = UInt32(rand)
        
        self.addChild(sprite)
        sprite.runAction(followArc) {
            sprite.removeFromParent()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let object:SKPhysicsBody!
        
        //if bodyA is an object
        if contact.bodyA.categoryBitMask > 0 {
            object = contact.bodyA
        } else {
            //bodyA is the player, instead use bodyB
            object = contact.bodyB
        }
        
        if object.categoryBitMask == 1 {
            if let thing = object.node {
                object.categoryBitMask = 4
                thing.removeFromParent()
                sceneDelegate?.updateScore(100)
            }
        } else {
            print(object.categoryBitMask)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        let mouth = (UIApplication.sharedApplication().delegate as! AppDelegate).mouth
        if !gameStarted {
            // detect open mouth to kick of gameTimer and start game
            if gameShouldStart(mouth) {
                gameStarted = true
                gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(setupNew), userInfo: nil, repeats: true)
            }
        }else {
            //        if we have data to work with
            if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
                //        create player position and draw shape based on mouth array
                if polygonNode != nil { polygonNode.removeFromParent() }
                addMouth(mouth)
            }
        }
    }
    
    func gameShouldStart(mouth:[CGPoint]) -> Bool {
        var shouldStart = false
        if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
            let p1 = mouth[2]
            let p2 = mouth[6]
            let distance = hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y));
            print(distance)
            if distance > 25 {
                shouldStart = true
                sceneDelegate?.hideInstructions()
            }
        }
        return shouldStart
    }
    
    func addMouth(mouth:[CGPoint]) {
        var anchorPoint:CGPoint!
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        
        var center = self.view!.convertPoint( CGPointMake( (mouth[2].x + mouth[6].x) / 2, (mouth[2].y + mouth[6].y) / 2), toScene: self)
        center = CGPointMake(center.x+50,center.y-100)
        for m in mouth {
            let mm = self.view!.convertPoint(m, toScene: self)
            if m == mouth.first! {
                anchorPoint = mm
                CGPathMoveToPoint(pathToDraw, nil, mm.x, mm.y)
            } else {
                CGPathAddLineToPoint(pathToDraw, nil, mm.x, mm.y)
            }
        }
        CGPathAddLineToPoint(pathToDraw, nil, anchorPoint.x, anchorPoint.y)
        polygon = SKShapeNode(path: pathToDraw)
        polygon.antialiased = true
        polygon.strokeColor = SKColor.greenColor()
        polygon.fillColor = SKColor.greenColor()
        polygon.name = "mouthshape"

        let texture = view!.textureFromNode(polygon)
        polygonNode = SKSpriteNode(texture: texture, size: polygon.calculateAccumulatedFrame().size)
        polygonNode.physicsBody = SKPhysicsBody(texture: polygonNode.texture!, size: polygonNode.calculateAccumulatedFrame().size)
        
        polygonNode.name = "mouthnode"
        polygonNode.position = center
        
        polygonNode.physicsBody!.contactTestBitMask = 1 | 2
        polygonNode.physicsBody!.categoryBitMask = 0
        self.addChild(polygonNode)

    }
    
    func rotatePoint(target: CGPoint, aroundOrigin origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = target.x - origin.x
        let dy = target.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byDegrees * CGFloat(M_PI / 180.0) // convert it to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
    
    func arcBetweenPoints(view : SKView, fromPoint start : CGPoint, toPoint end: CGPoint) -> CGPath {
        
        // Animation's path
        let path = UIBezierPath()
        
        // Move the "cursor" to the start
        path.moveToPoint(start)
        
        // Calculate the control points
        let factor : CGFloat = 0.5
        
        let deltaX : CGFloat = end.x - start.x
        let deltaY : CGFloat = end.y - start.y
        
        let c1 = CGPoint(x: start.x + deltaX * factor, y: start.y)
        let c2 = CGPoint(x: end.x, y: end.y - deltaY * factor)
        
        // Draw a curve towards the end, using control points
        path.addCurveToPoint(end, controlPoint1:c1, controlPoint2:c2)
        
        //        let curve = SKShapeNode()
        //        curve.path = path.CGPath
        //        curve.lineWidth = 4
        //        curve.strokeColor = UIColor.redColor()
        //        self.addChild(curve)
        
        // Use this path as the animation's path (casted to CGPath)
        return path.CGPath;
    }

    func pauseHandler(willPause: Bool) {
        if willPause {
            scene?.view?.paused = true
            print("pause game")
//            if let _ = gameTimer {
                gameTimer.invalidate()
//            }
        } else {
//            if gameStarted {
                scene?.view?.paused = false
                print("resume game")
                gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(setupNew), userInfo: nil, repeats: true)
//            }
        }
    }
}
