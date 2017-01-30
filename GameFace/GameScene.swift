//
//  GameScene.swift
//  Space Race
//
//  Created by Jason Eng on 9/13/15.
//  Copyright (c) 2015 EngJason. All rights reserved.
//

import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol GameSceneDelegate: class {
    func updateTimer(_ countDown:Double)
    func getTimer() -> Double
    func swapInstructionsWithScore()
    func loadPostGame()
    func startGamePlay()
    func getSpeed() -> CGFloat
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
    
    var mouthSprite:SKSpriteNode!
    var mouthShape:SKShapeNode!

    var shadesSprite:SKSpriteNode!
    var stacheSprite:SKSpriteNode!
    
    var possibleObjects = [Sprite.candy.rawValue, Sprite.bomb.rawValue]
    var gameTimer: Timer!
    
    var lastState:GameState = .postGame
    
    var frameUpdateStartTime:TimeInterval?
    var endTime:TimeInterval!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func didMove(to view: SKView) {
        setupInterface()
    }
    
    func setupInterface(){        
//        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func setupNew() {
        if frameUpdateStartTime == nil { frameUpdateStartTime = NSDate.timeIntervalSinceReferenceDate }
        endTime = NSDate.timeIntervalSinceReferenceDate
        let elapsedSec = endTime - frameUpdateStartTime!
        let realSecInterval = (gameVarDelegate?.getSpawnRate())! * 1 / Double((sceneDelegate?.getSpeed())!)
        
        if elapsedSec >= realSecInterval {
            guard gameVarDelegate != nil else {return}
            guard gameVarDelegate?.getSpriteInitialSpeed() != nil else {return}
            
            let start = CGPoint(x: RandomCGFloat(0, max: self.frame.width), y: self.frame.height)
            let end = CGPoint(x: RandomCGFloat(self.frame.width * 1/CGFloat(gameVarDelegate!.getSpriteEndRange()),
                                               max: self.frame.width * CGFloat(gameVarDelegate!.getSpriteEndRange() - 1)/CGFloat(gameVarDelegate!.getSpriteEndRange())), y: 0)
            createNew(fromPoint: start, toPoint: end)
            
            frameUpdateStartTime = nil
        }
    }
    
    func createNew(fromPoint start : CGPoint, toPoint end: CGPoint) {
        guard gameVarDelegate != nil else {return}
        guard gameVarDelegate?.getSpriteInitialSpeed() != nil else {return}
        guard gameVarDelegate?.getGameScoreBonus() != nil else {return}
        guard gameVarDelegate?.getSpriteSize() != nil else {return}
        guard gameVarDelegate?.getWillAddBombs() != nil else {return}
        
        guard sceneDelegate != nil else {return}
        guard sceneDelegate?.getSpeed() != nil else {return}
        
        //1 is good 2 is bad
        var rand = 1
        if gameVarDelegate!.getWillAddBombs() { rand = RandomInt(1, max: 2) }
        
        let sprite = SKSpriteNode(imageNamed: possibleObjects[rand - 1])
        sprite.size = CGSize(width: gameVarDelegate!.getSpriteSize(), height: gameVarDelegate!.getSpriteSize())
        let path = arcBetweenPoints(fromPoint: start, toPoint: end)
        
        sprite.position = start
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = UInt32(rand)
        
        if rand == 1 {
            sprite.name = Sprite.candy.rawValue
        } else {
            sprite.name = Sprite.bomb.rawValue
        }
        
        self.addChild(sprite)
//        spriteRunAction(sprite: sprite, path: path, key: "orig")
    }
    
    func spriteRunAction(sprite:SKSpriteNode, path:CGPath, key: String) {
        let followArc = SKAction.follow(path, asOffset: false, orientToPath: true, duration: gameVarDelegate!.getSpriteInitialSpeed())
        sprite.run(action: followArc, withKey: key, optionalCompletion: { [unowned self] in
            
            if sprite.name == Sprite.candy.rawValue {
                if (sprite.action(forKey: "orig") != nil) {
//                    print("completion - candy missed")
                    self.registerBadOutcome(sprite: sprite)
                } else {
//                    print("completion - candy caught")
                    self.registerGoodOutcome(sprite: sprite)
                }
            }
            
            if sprite.name == Sprite.bomb.rawValue {
//                print("completion - bomb dodged")
                self.registerNeutralOutcome(sprite: sprite)
            }
        })
    }
    
    func triggerExplosion(sprite:SKSpriteNode) {
        let emitterNode = SKEmitterNode(fileNamed: "explosion.sks")
        emitterNode!.particlePosition = sprite.position
        self.addChild(emitterNode!)
        self.run(SKAction.wait(forDuration: 2), completion: {
            emitterNode!.removeFromParent()
        })
    }
    
    func triggerShrink(sprite:SKSpriteNode) {
        let emitterNode = SKEmitterNode(fileNamed: "candyEater.sks")
        emitterNode!.particlePosition = sprite.position
        self.addChild(emitterNode!)
        self.run(SKAction.wait(forDuration: 2), completion: {
            emitterNode!.removeFromParent()
        })
    }
    
    func registerGoodOutcome(sprite: SKSpriteNode) {
        triggerShrink(sprite: sprite)
        sprite.removeFromParent()
        sceneDelegate?.updateTimer((gameVarDelegate?.getGameScoreBonus())! / 10.0)
        addCredit(by: 1)
    }
    
    func registerBadOutcome(sprite: SKSpriteNode) {
        triggerExplosion(sprite: sprite)
        sprite.removeFromParent()
        sceneDelegate?.updateTimer((gameVarDelegate?.getGameScoreBonus())! / -10.0)
    }
    
    func registerNeutralOutcome(sprite: SKSpriteNode) {
        sprite.removeFromParent()
    }
    
    func addCredit(by amount:Int){
        appDelegate.credits += amount
//        print("total credits: \(appDelegate.credits)")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var sprite:SKSpriteNode!

        if contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4 { return }
        
        if contact.bodyA.node?.name == Sprite.mouth.rawValue {
            if let object = contact.bodyB.node as? SKSpriteNode{
                sprite = object
            }
        } else if contact.bodyB.node?.name == Sprite.mouth.rawValue {
            if let object = contact.bodyA.node as? SKSpriteNode{
                sprite = object
            }
        }
        
        guard sprite != nil else { return }
        
        sprite.physicsBody?.categoryBitMask = 4
        
        if sprite.name == Sprite.candy.rawValue {
//            print("contact - candy caught")
            registerGoodOutcome(sprite: sprite)
        }
        
        if sprite.name == Sprite.bomb.rawValue {
//            print("contact - bomb caught")
            registerBadOutcome(sprite: sprite)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
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
            (appDelegate.window?.rootViewController as! GameGallery).collectionView.isScrollEnabled = false
            if mouthSprite != nil { mouthSprite.removeFromParent() }
            if shadesSprite != nil { shadesSprite.removeFromParent() }
            if stacheSprite != nil { stacheSprite.removeFromParent() }

            //        if we have data to work with
            if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
                //        create player position and draw shape based on mouth array
                if checkMouth(mouth, dist: 5){
                    addMouth(mouth)
                    
//use when we get boost fps - it will stop showing sprite if face is not detected, but then sprites give off strobe effect
//                    appDelegate.mouth = []
                    sceneDelegate?.updateTimer((gameVarDelegate?.getOpenMouthDrainRate())! * -1.0 / 1000)
                }else {
                    sceneDelegate?.updateTimer((gameVarDelegate?.getClosedMouthDrainRate())! * -1.0 / 1000)
                }
            }
            
            let allNodes:[SKNode] = (scene?.children)!
            
            for node in allNodes {
                if node is SKSpriteNode {
                    if (node.physicsBody?.categoryBitMask)! > 0 {
//                        node.speed = sceneDelegate!.getSpeed()
                        if node.position.y < 200 {
                            node.removeFromParent()
                        }
                        
                        if appDelegate.activePowerups.contains(.slomo) {
                            node.physicsBody?.velocity.dy *= 0.5
                        }
                    }
                    
                    if appDelegate.activePowerups.contains(.catchall) {
//                        node.physicsBody
                    }
                    
//                    if !mouth.isEmpty && (node.physicsBody?.categoryBitMask)! == 1 && appDelegate.activePowerups.contains(PowerUp.catchall) {
//                        if (node.action(forKey: "orig") != nil) {
//                            node.removeAllActions()
//                            let newPath = arcBetweenPoints(fromPoint: node.position, toPoint: self.view!.convert( calcCenter(point1: mouth[2], point2: mouth[6]), to: self))
//                            spriteRunAction(sprite: node as! SKSpriteNode, path: newPath, key: "catchAll")
//                        }
//                    }
                }
            }
            
            if !appDelegate.activePowerups.isEmpty {
                sceneDelegate?.updateTimer((gameVarDelegate?.getOpenMouthDrainRate())! * -2.0 * Double(appDelegate.activePowerups.count) / 1000)
                if appDelegate.noseBridge != nil && appDelegate.activePowerups.contains(PowerUp.slomo) { addShades(appDelegate.noseBridge) }
                if appDelegate.mustache != nil && appDelegate.activePowerups.contains(PowerUp.catchall) { addStache(appDelegate.mustache) }
            }
            
            if gameVarDelegate!.getWillRecordGame() {
                if (appDelegate.window?.rootViewController as! GameGallery).gamePlayArray.count >= Int( 30 * gameVarDelegate!.getVideoLength() ) {
                    (appDelegate.window?.rootViewController as! GameGallery).gamePlayArray.removeFirst()
                }
                
//apparently we don't need to go to the background just drawhierarchy without screenupdates
//                DispatchQueue.global(qos: .background).async { [unowned self]() -> Void in
                    (self.appDelegate.window?.rootViewController as! GameGallery).takeScreenShot()
//                }
            }
        }
    }
    
    func triggerGameStart(_ mouth:[CGPoint]) -> Bool {
        guard appDelegate.currentCell != nil else { return false }
        guard (gameVarDelegate?.getGameStartMouthDist() != nil) else { return false }
        
        if appDelegate.currentCell == 1 && checkMouth(mouth, dist: (gameVarDelegate?.getGameStartMouthDist())!) { return true }
        return false
    }
    
    func checkMouth(_ mouth:[CGPoint], dist:Float) -> Bool{
        if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
            let p1 = mouth[2]
            let p2 = mouth[6]
            let distance = hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y));
            if distance > dist { return true }
        }
        return false
    }
    
    func addMouth(_ mouth:[CGPoint]) {
        
        var anchorPoint:CGPoint!
        let pathToDraw:CGMutablePath = CGMutablePath()
        
        let center = calcCenter(point1: mouth[2], point2: mouth[6])

        for m in mouth {
            let mm = self.view!.convert(m, to: self)
            if m == mouth.first! {
                anchorPoint = mm
                pathToDraw.move(to: mm)
            } else {
                pathToDraw.addLine(to: mm)
            }
        }
        pathToDraw.addLine(to: anchorPoint)
        
        mouthShape = SKShapeNode(path: pathToDraw)
        mouthShape.isAntialiased = true
        mouthShape.strokeColor = UIColor.cyan//RandomColor()
//        polygon.fillColor = RandomColor()
        mouthShape.name = "mouthshape"

        let texture = view!.texture(from: mouthShape)
        mouthSprite = SKSpriteNode(texture: texture, size: mouthShape.calculateAccumulatedFrame().size)
        mouthSprite.physicsBody = SKPhysicsBody(texture: mouthSprite.texture!, size: mouthSprite.calculateAccumulatedFrame().size)
        
        mouthSprite.name = Sprite.mouth.rawValue
        mouthSprite.position = self.view!.convert(center, to: self)
        
        mouthSprite.physicsBody!.contactTestBitMask = 1 | 2
        mouthSprite.physicsBody!.categoryBitMask = 0
        self.addChild(mouthSprite)

    }
    
    func calcCenter(point1:CGPoint, point2:CGPoint) -> CGPoint {
        return CGPoint( x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
    
    func addShades(_ position:CGPoint){
        shadesSprite = SKSpriteNode(imageNamed: "shades")
        shadesSprite.aspectFillToSize(CGSize(width: 100, height: 100))
        shadesSprite.position = self.view!.convert(position, to: self)
        shadesSprite.zPosition = -100
        shadesSprite.physicsBody = SKPhysicsBody(texture: shadesSprite.texture!, size: shadesSprite.size)
        shadesSprite.physicsBody?.categoryBitMask = UInt32(0)
        shadesSprite.physicsBody?.contactTestBitMask = 0
        shadesSprite.physicsBody?.collisionBitMask = 0
        self.addChild(shadesSprite)
    }
    
    func addStache(_ position:CGPoint){
        stacheSprite = SKSpriteNode(imageNamed: "mustache")
        stacheSprite.aspectFillToSize(CGSize(width: 50, height: 50))
        stacheSprite.position = self.view!.convert(position, to: self)
        stacheSprite.zPosition = -100
        stacheSprite.physicsBody = SKPhysicsBody(texture: stacheSprite.texture!, size: stacheSprite.size)
        stacheSprite.physicsBody?.categoryBitMask = UInt32(0)
        stacheSprite.physicsBody?.contactTestBitMask = 0
        stacheSprite.physicsBody?.collisionBitMask = 0
        self.addChild(stacheSprite)
    }
    
    func arcBetweenPoints(fromPoint start : CGPoint, toPoint end: CGPoint) -> CGPath {
        
        // Animation's path
        let path = UIBezierPath()
        
        // Move the "cursor" to the start
        path.move(to: start)
        
        // Calculate the control points
        let factor : CGFloat = 0.5
        
        let deltaX : CGFloat = end.x - start.x
        let deltaY : CGFloat = end.y - start.y
        
        let c1 = CGPoint(x: start.x + deltaX * factor, y: start.y)
        let c2 = CGPoint(x: end.x, y: end.y - deltaY * factor)
        
        // Draw a curve towards the end, using control points
        path.addCurve(to: end, controlPoint1:c1, controlPoint2:c2)
        
//        debugDrawCurvePath(path.cgPath)
        
        // Use this path as the animation's path (casted to CGPath)
        return path.cgPath;
    }

    func debugDrawCurvePath(_ cgPath:CGPath){
        let curve = SKShapeNode()
        curve.path = cgPath
        curve.lineWidth = 2
        curve.strokeColor = UIColor.red
        self.addChild(curve)
    }
        
    func updatePauseHandler(to state:GameState) {
        if state == .paused {
            appDelegate.gameState = .paused
            scene?.view?.isPaused = true
            print("pause game")
            gameTimer.invalidate()
        } else {
            appDelegate.gameState = .inPlay
            scene?.view?.isPaused = false
            print("resume game")
            addGameTimer()
        }
    }
    
    func addGameTimer(){
        guard gameVarDelegate?.getSpawnRate() != nil else { return }
        guard sceneDelegate?.getSpeed() != nil else { return }
        
        //need to run timer every milisecond but then do a secondary interval to determine when to actually spawn game sprites
        gameTimer = Timer.scheduledTimer(timeInterval: 1/1000, target: self, selector: #selector(setupNew), userInfo: nil, repeats: true)
    }

}
