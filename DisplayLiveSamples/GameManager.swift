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
    
    var scoreLabel: SKLabelNode!
    var scoreShadow: SKLabelNode!
    var pauseButton:SKSpriteNode!
    var gameIsPaused = false
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
        
        pauseButton = SKSpriteNode(imageNamed: "tv")
        pauseButton.size = CGSizeMake(length, length)
        pauseButton.position = CGPoint(x: self.frame.width - length, y: self.frame.height - length)
        addChild(pauseButton)

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
                if (gameIsPaused) {
                    managerDelegate?.pauseHandler(false)
                }else {
                    managerDelegate?.pauseHandler(true)
                }
                gameIsPaused = !gameIsPaused
            }
        }
    }
}