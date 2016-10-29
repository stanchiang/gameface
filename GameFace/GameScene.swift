//
//  GameScene.swift
//  Space Race
//
//  Created by Jason Eng on 9/13/15.
//  Copyright (c) 2015 EngJason. All rights reserved.
//

import SpriteKit

protocol GameSceneDelegate: class {
    func updateTimer(countDown:Double)
    func getTimer() -> Double
    func swapInstructionsWithScore()
    func loadPostGame()
    func startGamePlay()
}

protocol GameVarDelegate: class {
    func getGameStartMouthDist() -> Float
    func getOpenMouthDrainRate() -> Double
    func getClosedMouthDrainRate() -> Double
    func getGameScoreBonus() -> Double
    func getAdjustedPPI() -> CGFloat
    func getSpawnRate() -> Double
    func getSpriteInitialSpeed() -> Double
    func getSpriteSize() -> Double
    func getSpriteEndRange() -> Double
    func getVideoLength() -> Double
    func getWillRecordGame() -> Bool
    func getWillAddBombs() -> Bool
    func getWillShowFaceDetect() -> Bool
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameManagerDelegate {
    
    weak var sceneDelegate:GameSceneDelegate?
    weak var gameVarDelegate:GameVarDelegate?
    
    var polygonNode:SKSpriteNode!
    var polygon:SKShapeNode!

    var possibleObjects = ["candy", "bomb"]
    var gameTimer: NSTimer!
    
    var objectMissedCount = 0;
    
    var lastState:GameState = .postGame
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func didMoveToView(view: SKView) {
        setupInterface()
    }
    
    func setupInterface(){        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

    }
    
    func setupNew() {
        guard gameVarDelegate != nil else {return}
        guard gameVarDelegate?.getSpriteInitialSpeed() != nil else {return}
        
        let start = CGPointMake(RandomCGFloat(0, max: self.frame.width), self.frame.height)
        let end = CGPointMake(RandomCGFloat(self.frame.width * 1/CGFloat(gameVarDelegate!.getSpriteEndRange()),
            max: self.frame.width * CGFloat(gameVarDelegate!.getSpriteEndRange() - 1)/CGFloat(gameVarDelegate!.getSpriteEndRange())), 0)
        
        createNew(fromPoint: start, toPoint: end)
    }
    
    func createNew(fromPoint start : CGPoint, toPoint end: CGPoint) {
        guard gameVarDelegate != nil else {return}
        guard gameVarDelegate?.getSpriteInitialSpeed() != nil else {return}
        guard gameVarDelegate?.getGameScoreBonus() != nil else {return}
        guard gameVarDelegate?.getSpriteSize() != nil else {return}
        guard gameVarDelegate?.getWillAddBombs() != nil else {return}
        
        //1 is good 2 is bad
        var rand = 1
        if gameVarDelegate!.getWillAddBombs() {
            rand = RandomInt(1, max: 2)
        }
        
        let sprite = SKSpriteNode(imageNamed: possibleObjects[rand - 1])
        sprite.size = CGSize(width: gameVarDelegate!.getSpriteSize(), height: gameVarDelegate!.getSpriteSize())
        let path = arcBetweenPoints(fromPoint: start, toPoint: end)
        let followArc = SKAction.followPath(path, asOffset: false, orientToPath: true, duration: gameVarDelegate!.getSpriteInitialSpeed())
        
        sprite.position = start
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = UInt32(rand)
        
        self.addChild(sprite)
        sprite.runAction(followArc) { [unowned self] in
            
            if sprite.physicsBody?.categoryBitMask == 1 {
                let emitterNode = SKEmitterNode(fileNamed: "explosion.sks")
                emitterNode!.particlePosition = sprite.position
                self.addChild(emitterNode!)
                self.runAction(SKAction.waitForDuration(2), completion: {
                    emitterNode!.removeFromParent()
                })
                
                sprite.removeFromParent()
                print("candy missed")
                self.objectMissedCount += 1
                self.sceneDelegate?.updateTimer(self.gameVarDelegate!.getGameScoreBonus() / -10.0)
            }
            
            if sprite.physicsBody?.categoryBitMask == 2 {
                sprite.removeFromParent()
                print("bomb dodged")
//                self.sceneDelegate?.updateTimer(self.gameVarDelegate!.getGameScoreBonus() / 10.0)
            }
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
                
                let emitterNode = SKEmitterNode(fileNamed: "candyEater.sks")
                emitterNode!.particlePosition = thing.position
                self.addChild(emitterNode!)
                self.runAction(SKAction.waitForDuration(2), completion: {
                    emitterNode!.removeFromParent()
                })
                thing.removeFromParent()
                sceneDelegate?.updateTimer((gameVarDelegate?.getGameScoreBonus())! / 10.0)
            }
        }
        
        if object.categoryBitMask == 2 {
            if let thing = object.node {
                object.categoryBitMask = 4
                
                let emitterNode = SKEmitterNode(fileNamed: "explosion.sks")
                emitterNode!.particlePosition = thing.position
                self.addChild(emitterNode!)
                self.runAction(SKAction.waitForDuration(2), completion: {
                    emitterNode!.removeFromParent()
                })
                thing.removeFromParent()
                sceneDelegate?.updateTimer((gameVarDelegate?.getGameScoreBonus())! / -10.0)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        guard gameVarDelegate != nil else { return }
        guard gameVarDelegate?.getWillRecordGame() != nil else { return }
        guard gameVarDelegate?.getVideoLength() != nil else { return }
        
        if lastState != appDelegate.gameState {
            lastState = appDelegate.gameState
            print(lastState)
        }
        
        if appDelegate.gameState == .inPlay && sceneDelegate?.getTimer() <= 0 {
            appDelegate.gameState = .postGame
            if gameVarDelegate!.getWillRecordGame() {
                sceneDelegate?.loadPostGame()
            } else {
                (appDelegate.window?.rootViewController as! GameGallery).resetGame()
            }
            
        }
        
        let mouth = appDelegate.mouth
        if appDelegate.gameState == .preGame {
            if triggerGameStart(mouth) {
                sceneDelegate?.swapInstructionsWithScore()
                sceneDelegate?.startGamePlay()
            }
        }
        
        if appDelegate.gameState == .inPlay {
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
            
            if gameVarDelegate!.getWillRecordGame() {
                if (appDelegate.window?.rootViewController as! GameGallery).gamePlayArray.count >= Int( 30 * gameVarDelegate!.getVideoLength() ) {
                    (appDelegate.window?.rootViewController as! GameGallery).gamePlayArray.removeFirst()
                }
                (appDelegate.window?.rootViewController as! GameGallery).takeScreenShot()
            }
        }
    }
    
    func triggerGameStart(mouth:[CGPoint]) -> Bool {
        guard appDelegate.currentCell != nil else {
            return false
        }
        guard (gameVarDelegate?.getGameStartMouthDist() != nil) else {
            return false
        }
        if appDelegate.currentCell == 1 && checkMouth(mouth, dist: (gameVarDelegate?.getGameStartMouthDist())!) {
            return true
        }
        return false
    }
    
    func checkMouth(mouth:[CGPoint], dist:Float) -> Bool{
        if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
            let p1 = mouth[2]
            let p2 = mouth[6]
            let distance = hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y));
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
//        polygon.fillColor = RandomColor()
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
            appDelegate.gameState = .paused
            scene?.view?.paused = true
            print("pause game")
            gameTimer.invalidate()
        } else {
            appDelegate.gameState = .inPlay
            scene?.view?.paused = false
            print("resume game")
            addGameTimer()
        }
    }
    
    func addGameTimer(){
        guard gameVarDelegate?.getSpawnRate() != nil else {
            return
        }
        gameTimer = NSTimer.scheduledTimerWithTimeInterval((gameVarDelegate?.getSpawnRate())!, target: self, selector: #selector(setupNew), userInfo: nil, repeats: true)
    }
}
