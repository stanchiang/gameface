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
    func loadPostGame()
    func startPlaying()
}

class GameManager: SKScene, GameSceneDelegate {
    weak var managerDelegate:GameManagerDelegate?
    weak var uikitDelegate:UIKitDelegate?
    var instructions:SKLabelNode!
    var pauseButton:SKSpriteNode!
    
    let length:CGFloat = 50
    var timer:SKSpriteNode!
    var scoreTitle:SKLabelNode!
    var scoreValue:SKLabelNode!
    var highScoreOnStart:SKLabelNode!
    
    var startTime = NSTimeInterval()

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var hasNewHighScore = false
    
    override func didMoveToView(view: SKView) {
        setupInterface()
    }
    
    func setupInterface() {
        addTimer()
        addInstructions()
        addHighScoreOnStartLabel()
    }
    
    func addScoreValue() {
        scoreValue = SKLabelNode()
        scoreValue.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.925)
        scoreValue.text = "00.00.00"
        scoreValue.fontColor = UIColor(netHex: 0x5C5854)
        scoreValue.fontName = "San Francisco-Bold"
        scoreValue.fontSize = 40
        addChild(scoreValue)
    }
    
    func addScoreTitle(){
        scoreTitle = SKLabelNode()
        scoreTitle.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.8755)
        scoreTitle.text = "score"
        scoreTitle.fontName = "San Francisco-Medium"
        scoreTitle.fontColor = UIColor(netHex: 0x5C5854)
        addChild(scoreTitle)
    }
    
    func addInstructions(){
        instructions = SKLabelNode(fontNamed: "San Francisco-Bold")
        instructions.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.9)
        instructions.text = "Open Your Mouth 😮"
        instructions.fontColor = UIColor(netHex: 0x5C5854)
        addChild(instructions)
    }
    
    func addHighScoreOnStartLabel(){
        highScoreOnStart = SKLabelNode(fontNamed: "San Francisco")
        highScoreOnStart.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.825)
        
        let parsedTime = NSTimeInterval(appDelegate.highScore).parseTime()
        let strMinutes = String(format: "%02d", parsedTime.0)
        let strSeconds = String(format: "%02d", parsedTime.1)
        let strFraction = String(format: "%02d", parsedTime.2)

        highScoreOnStart.text = "highscore: \(strMinutes).\(strSeconds).\(strFraction)"
        highScoreOnStart.fontColor = UIColor(netHex: 0x5C5854)
        highScoreOnStart.fontSize = 20
        addChild(highScoreOnStart)
    }
    
    func addPause(length:CGFloat){
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSizeMake(length, length)
        pauseButton.position = CGPoint(x: self.frame.width - length, y: self.frame.height - length)
        addChild(pauseButton)
    }
    
    func addTimer(){
        timer = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: UIScreen.mainScreen().bounds.width, height: self.frame.height * 0.40))
        timer.alpha = 0.5
        timer.anchorPoint.x = 0
        timer.position = CGPoint(x: 0, y: self.frame.height)
        addChild(timer)
    }
    
    func updateScore() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        let elapsedTime: NSTimeInterval = currentTime - startTime
        appDelegate.currentScore = elapsedTime
//        print(appDelegate.currentScore)
        
        let parsedTime = elapsedTime.parseTime()
        
        let strMinutes = String(format: "%02d", parsedTime.0)
        let strSeconds = String(format: "%02d", parsedTime.1)
        let strFraction = String(format: "%02d", parsedTime.2)
        
        if !hasNewHighScore && appDelegate.currentScore > appDelegate.highScore {
            hasNewHighScore = true
        }
        
        if hasNewHighScore {
            scoreValue.text = "🎉🎉\(strMinutes).\(strSeconds).\(strFraction)🎉🎉"
        } else {
            scoreValue.text = "\(strMinutes).\(strSeconds).\(strFraction)"
        }
        
    }
    
    func updateTimer(rate: Double) {
        timer.xScale += CGFloat(rate)
        if timer.xScale > 1.0 { timer.xScale = 1.0 }
        timer.color = updateTimerColor(timer.xScale)
        
        updateScore()
    }
    
    func updateTimerColor(xScale:CGFloat) -> UIColor {
        switch xScale {
        case  _ where xScale > 0.5 :
            return UIColor.greenColor()//UIColor(netHex:0x7ED321) //green
        case  _ where xScale > 0.25 :
            return UIColor(netHex:0xF8E71C) //yellow
        default:
            return UIColor(netHex:0xD0021B) //red
        }
    }
    
    func getTimer() -> Double {
        return Double(timer.xScale)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Loop over all the touches in this event
//        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
//            let location = touch.locationInNode(self)
            // Check if the location of the touch is within the button's bounds
//            if pauseButton.containsPoint(location) {
//                togglePause()
//            }
//        }
    }
    
    func togglePause(){
        if (appDelegate.gameState == .paused) {
            managerDelegate?.updatePauseHandler(to: .inPlay)
        }else {
            managerDelegate?.updatePauseHandler(to: .paused)
        }
        
        toggleOptionsMenu()
    }
    
    func toggleOptionsMenu() {
        print("toggle options menu")
    }
    
    func swapInstructionsWithScore() {
        instructions.removeFromParent()
        
        addScoreTitle()
        addScoreValue()
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func loadPostGame() {
        uikitDelegate?.loadPostGame()
    }
    
    func startGamePlay() {
        uikitDelegate?.startPlaying()
    }
}
