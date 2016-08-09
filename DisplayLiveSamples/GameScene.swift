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
    var polygonNode:SKSpriteNode!
    var polygon:SKShapeNode!
    var scoreLabel: SKLabelNode!
    var transform:CGAffineTransform?
    var isInitialDrawing = true
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: NSTimer!
    var gameOver = false
    
    override func didMoveToView(view: SKView) {
        
        transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        transform = CGAffineTransformMakeScale(1, -1)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody!.contactTestBitMask = 1 | 2
        player.physicsBody!.categoryBitMask = 0
//        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .Left
//        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
//        gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.test), userInfo: nil, repeats: true)
        
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
//        var viewloc = touch.locationInView(self.view)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
        print(player.position)
//        print("viewLoc:\(viewloc)")
//        print(self.view?.convertPoint(location, fromScene: self))
//        
//        print("nodeLoc:\(location)")
//        print(self.view?.convertPoint(viewloc, toScene: self))
        
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
            explosion.position = polygonNode.position
            addChild(explosion)
            
            polygonNode.removeFromParent()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        let mouth = (UIApplication.sharedApplication().delegate as! AppDelegate).mouth
//        if we have data to work with
        if !mouth.isEmpty && mouth.first!.x != 0 && mouth.first!.y != 0 {
//        create player position and draw shape based on mouth array
            if isInitialDrawing {

                addMouth(mouth)

                isInitialDrawing = false
            } else {
//                update position and shape
                
//                polygon.path = nil
                if let poNo = childNodeWithName("mouthnode") {
                    print(poNo.position)
                    poNo.removeFromParent()

                } else {
                    print("mouth node not found")
                }

                addMouth(mouth)
            }
        }
    }
    
    func addMouth(mouth:[CGPoint]) {
        var anchorPoint:CGPoint!
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        
        var center = self.view!.convertPoint( CGPointMake( (mouth[2].x + mouth[6].x) / 2, (mouth[2].y + mouth[6].y) / 2), toScene: self)
        
        var trueCenter = self.view!.convertPoint(CGPointMake(414/2.0, 736/2.0), toScene: self)
//        print("from \(self.view!.convertPoint(center, fromScene: self))")
//        var newcenter = self.view!.convertPoint(center, fromScene: self)
        center = rotatePoint(center, aroundOrigin: trueCenter, byDegrees: -90)
//        newcenter = CGPointApplyAffineTransform(newcenter, CGAffineTransformMakeRotation(CGFloat(M_PI)))
//        newcenter = CGPointApplyAffineTransform(newcenter, CGAffineTransformMakeScale(1, -1))
//        center = self.view!.convertPoint(newcenter, toScene: self)
//        print("to \(self.view!.convertPoint(center, fromScene: self))")
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
        polygon.strokeColor = SKColor.redColor()
        polygon.fillColor = SKColor.redColor()
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
}
