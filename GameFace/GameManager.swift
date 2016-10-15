//
//  GameManager.swift
//  DisplayLiveSamples
//
//  Created by Stanley Chiang on 8/15/16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import SpriteKit

protocol GameManagerDelegate: class {
    func updatePauseHandler(to state:GameState)
}

protocol UIKitDelegate: class {
    func loadPostGameModal()
    func startRecording()
}

class GameManager: SKScene, GameSceneDelegate {
    weak var managerDelegate:GameManagerDelegate?
    weak var uikitDelegate:UIKitDelegate?
    var instructions:SKLabelNode!
    var scoreLabel: SKLabelNode!
    var scoreShadow: SKLabelNode!
    var pauseButton:SKSpriteNode!
    var timer:SKSpriteNode!
    
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
        
        addScore(length, offset: offset)
//        addPause(length)
        addTimer(length)
        addInstructions(length)

    }
    
    func addInstructions(length:CGFloat){
        instructions = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        instructions.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height - length * 2)
        instructions.horizontalAlignmentMode = .Center
        instructions.text = "loading..."
        instructions.fontColor = UIColor.blackColor()
        addChild(instructions)
    }
    
    func addPause(length:CGFloat){
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSizeMake(length, length)
        pauseButton.position = CGPoint(x: self.frame.width - length, y: self.frame.height - length)
        addChild(pauseButton)
    }
    
    func addScore(length:CGFloat, offset:CGFloat) {
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
    }
    
    func addTimer(length:CGFloat){
        timer = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: UIScreen.mainScreen().bounds.width, height: 30))
        timer.anchorPoint.x = 0
        timer.position = CGPoint(x: 0, y: self.frame.height - length * 2)
        addChild(timer)
    }
    
    func updateScore(points:Int) {
        score += points
    }
    
    func updateTimer(rate: Double) {
        timer.xScale += CGFloat(rate)
        if timer.xScale > 1.0 {
            timer.xScale = 1.0
        }
    }
    
    func getTimer() -> Double {
        return Double(timer.xScale)
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
        if ((UIApplication.sharedApplication().delegate as! AppDelegate).gameState == .paused) {
            managerDelegate?.updatePauseHandler(to: .inPlay)
        }else {
            managerDelegate?.updatePauseHandler(to: .paused)
        }
        
        toggleOptionsMenu()
    }
    
    func toggleOptionsMenu() {
        print("toggle options menu")
    }
    
    func hideInstructions() {
        instructions.removeFromParent()
    }
    
    func loadPostGame() {
        uikitDelegate?.loadPostGameModal()
    }
    
    func startRecordingGamePlay() {
        uikitDelegate?.startRecording()
    }
}
