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
    var pauseButton:SKSpriteNode!
    var gameIsPaused = false
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        setupInterface()
        
    }
    
    func setupInterface() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 25, y: self.frame.height - 25)
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        pauseButton = SKSpriteNode(imageNamed: "tv")
        pauseButton.size = CGSizeMake(25, 25)
        pauseButton.position = CGPoint(x: self.frame.width - 25, y: self.frame.height - 25)
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