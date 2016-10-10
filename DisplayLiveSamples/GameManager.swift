//
//  GameManager.swift
//  DisplayLiveSamples
//
//  Created by Stanley Chiang on 8/15/16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import SpriteKit

protocol GameManagerDelegate: class {
    func pauseHandler(willPause:Bool)
}

class GameManager: SKScene, GameSceneDelegate {
    weak var managerDelegate:GameManagerDelegate?
    var instructions:SKLabelNode!
    var scoreLabel: SKLabelNode!
    var scoreShadow: SKLabelNode!
    var pauseButton:SKSpriteNode!
    
    var gameState = (UIApplication.sharedApplication().delegate as! AppDelegate).gameState
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            scoreShadow.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        setupInterface()
        
    }
    
    func setupInterface() {

        let length:CGFloat = 50
        let offset:CGFloat = 3
        
        scoreShadow = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        scoreShadow.position = CGPoint(x: length - offset, y: self.frame.height - (length + offset))
        scoreShadow.horizontalAlignmentMode = .Left
        scoreShadow.text = "Score: \(score)"
        scoreShadow.fontColor = UIColor.blackColor()
        addChild(scoreShadow)
        
        scoreLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        
        scoreLabel.position = CGPoint(x: length, y: self.frame.height - length)
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSizeMake(length, length)
        pauseButton.position = CGPoint(x: self.frame.width - length, y: self.frame.height - length)
        addChild(pauseButton)

        instructions = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        instructions.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height - length * 2)
        instructions.horizontalAlignmentMode = .Center
        instructions.text = "Open Mouth to Start Game"
        instructions.fontColor = UIColor.blackColor()
        addChild(instructions)
        
    }
    
    func updateScore(points:Int) {
        score += points
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Loop over all the touches in this event
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.locationInNode(self)
            // Check if the location of the touch is within the button's bounds
            if pauseButton.containsPoint(location) {
                togglePause()
            }
        }
    }
    
    func togglePause(){
        toggleOptionsMenu()
        
        if (gameState == .paused) {
            managerDelegate?.pauseHandler(false)
            gameState = .inPlay
        }else {
            managerDelegate?.pauseHandler(true)
            gameState = .paused
        }
    }
    
    func toggleOptionsMenu() {
        
    }
    
    func hideInstructions() {
        instructions.removeFromParent()
    }
}
