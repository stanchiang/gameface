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
    func updateTimer(countDown:Double)
    func getTimer() -> Double
    func hideInstructions()
    func loadPostGame()
    func startRecordingGamePlay()
}

protocol GameVarDelegate: class {
    func getGameStartMouthDist() -> Float
    func getOpenMouthDrainRate() -> Double
    func getClosedMouthDrainRate() -> Double
    func getGameScoreBonus() -> Double
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameManagerDelegate {
    
    weak var sceneDelegate:GameSceneDelegate?
    weak var gameVarDelegate:GameVarDelegate?
    
    let colorArray = [UIColor.greenColor(), UIColor.blackColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.orangeColor(), UIColor.cyanColor(), UIColor.magentaColor(), UIColor.purpleColor(), UIColor.yellowColor()]
    var chosenColor = 0
    var polygonNode:SKSpriteNode!
    var polygon:SKShapeNode!

    var pauseButton:SKSpriteNode!

    var possibleEnemies = ["ball", "ball", "hammer"]
    var gameTimer: NSTimer!
    
    var objectMissedCount = 0;
    
    var backImg:UIImage!
    var frontImg:UIImage!
    
    var lastState:GameState = .postGame
    
    var alreadyStarting = false
    
    override func didMoveToView(view: SKView) {
        setupInterface()
    }
    
    func setupInterface(){        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

    }
    
    func setupNew() {
        let start = CGPointMake(RandomCGFloat(0, max: self.frame.width), self.frame.height)
        let end = CGPointMake(RandomCGFloat(self.frame.width * 1/5, max: self.frame.width * 4/5), 0)
        print("start \(start) | end \(end)")
        createNew(fromPoint: start, toPoint: end)
    }
    
    func createNew(fromPoint start : CGPoint, toPoint end: CGPoint) {
        //1 is good 2 is bad
//        let rand = RandomInt(1, max: 2)
        let rand = 1
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[rand])
        let path = arcBetweenPoints(fromPoint: start, toPoint: end)
        let followArc = SKAction.followPath(path, asOffset: false, orientToPath: true, duration: 1)
        
        sprite.position = start
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = UInt32(rand)
        
        self.addChild(sprite)
        sprite.runAction(followArc) {
            sprite.removeFromParent()
            print("object missed")
            self.objectMissedCount += 1
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
                sceneDelegate?.updateTimer((gameVarDelegate?.getGameScoreBonus())! / 10.0)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if alreadyStarting {
            return
        }
        
        if lastState != (UIApplication.sharedApplication().delegate as! AppDelegate).gameState {
            lastState = (UIApplication.sharedApplication().delegate as! AppDelegate).gameState
            print(lastState)
        }
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).gameState == .inPlay && sceneDelegate?.getTimer() <= 0 {
            sceneDelegate?.loadPostGame()
        }
        
        let mouth = (UIApplication.sharedApplication().delegate as! AppDelegate).mouth
        if (UIApplication.sharedApplication().delegate as! AppDelegate).gameState == .preGame {
            if triggerGameStart(mouth) {
                sceneDelegate?.hideInstructions()
                sceneDelegate?.startRecordingGamePlay()
            }
        }
        
        if (UIApplication.sharedApplication().delegate as! AppDelegate).gameState == .inPlay {
            //        if we have data to work with
            if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
                //        create player position and draw shape based on mouth array
                if polygonNode != nil { polygonNode.removeFromParent() }
                if checkMouth(mouth, dist: 5){
                    addMouth(mouth)
                    sceneDelegate?.updateTimer((gameVarDelegate?.getOpenMouthDrainRate())! * -1.0 / 1000)
                }else {
                    sceneDelegate?.updateTimer((gameVarDelegate?.getClosedMouthDrainRate())! * -1.0 / 1000)
                }
            }
        }
    }
    
    func triggerGameStart(mouth:[CGPoint]) -> Bool {
        guard ((gameVarDelegate?.getGameStartMouthDist()) != nil) else {
            return false
        }
        if (UIApplication.sharedApplication().delegate as! AppDelegate).currentCell == 1 && checkMouth(mouth, dist: (gameVarDelegate?.getGameStartMouthDist())!) {
            return true
        }
        return false
    }
    
    func checkMouth(mouth:[CGPoint], dist:Float) -> Bool{
        if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
            let p1 = mouth[2]
            let p2 = mouth[6]
            let distance = hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y));
//            print(distance)
            if distance > dist {
                return true
            }
        }
        return false
    }
    
    func addMouth(mouth:[CGPoint]) {
        
        var anchorPoint:CGPoint!
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        
        var center = self.view!.convertPoint( CGPointMake( (mouth[2].x + mouth[6].x) / 2, (mouth[2].y + mouth[6].y) / 2), toScene: self)
        center = CGPointMake(center.x,center.y)
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
        polygon.strokeColor = UIColor.cyanColor()//RandomColor()
        polygon.fillColor = UIColor.cyanColor()//RandomColor()
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
    
    func arcBetweenPoints(fromPoint start : CGPoint, toPoint end: CGPoint) -> CGPath {
        
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
        
//        debugDrawCurvePath(path.CGPath)
        
        // Use this path as the animation's path (casted to CGPath)
        return path.CGPath;
    }

    func debugDrawCurvePath(cgPath:CGPath){
        let curve = SKShapeNode()
        curve.path = cgPath
        curve.lineWidth = 4
        curve.strokeColor = UIColor.redColor()
        self.addChild(curve)
    }
    
    func updatePauseHandler(to state:GameState) {
        if state == .paused {
            (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .paused
            scene?.view?.paused = true
            print("pause game")
            gameTimer.invalidate()
        } else {
            (UIApplication.sharedApplication().delegate as! AppDelegate).gameState = .inPlay
            scene?.view?.paused = false
            print("resume game")
            addGameTimer()
        }
    }
    
    func addGameTimer(){
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(setupNew), userInfo: nil, repeats: true)
    }
}
