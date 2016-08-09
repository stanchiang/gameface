//
//  GameScene.swift
//  Space Race
//
//  Created by Jason Eng on 9/13/15.
//  Copyright (c) 2015 EngJason. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var polygon: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: NSTimer!
    var gameOver = false
    
    override func didMoveToView(view: SKView) {
        
//        let starfieldPath = NSBundle.mainBundle().pathForResource("Starfield", ofType: "sks")!
//        starfield = NSKeyedUnarchiver.unarchiveObjectWithFile(starfieldPath) as! SKEmitterNode
//        starfield.position = CGPoint(x: 1024, y: 384)
//        starfield.advanceSimulationTime(10)
//        addChild(starfield)
//        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody!.contactTestBitMask = 1 | 2
        player.physicsBody!.categoryBitMask = 0
        addChild(player)
        
        polygon = SKSpriteNode()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .Left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
//        gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: #selector(GameScene.createObject), userInfo: nil, repeats: true)
        
        for _ in 0 ..< 10 {
            createOther()
        }
    }
    
    func createOther() {
//        possibleEnemies.shuffle()
        //1 is good 2 is bad
        let rand = RandomInt(1, max: 2)
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[rand])
        sprite.position = CGPoint(x: 600, y: RandomInt(50, max: 736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = UInt32(rand)
//        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
//        sprite.physicsBody?.angularVelocity = 5
//        sprite.physicsBody?.linearDamping = 0
//        sprite.physicsBody?.angularDamping = 0
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        var location = touch.locationInNode(self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
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
                thing.removeFromParent()
                score += 100
            }
        } else {
            let explosionPath = NSBundle.mainBundle().pathForResource("explosion", ofType: "sks")!
            let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionPath) as! SKEmitterNode
            explosion.position = player.position
            addChild(explosion)
            
            player.removeFromParent()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
//        for node in children {
//            if node.position.x < -300 {
//                node.removeFromParent()
//            }
//        }
        let mouth = (UIApplication.sharedApplication().delegate as! AppDelegate).mouth
        
        if !mouth.isEmpty {
            for m in mouth {
                if m.x == 0 && m.y == 0 {
                    return
                }
            }
            //update player position and shape based on mouth array
            print(mouth)
        }
    }
}
