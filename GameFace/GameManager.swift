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
    
    var gameSpeed:CGFloat = 1
    
    var timer:SKSpriteNode!
    var scoreTitle:SKLabelNode!
    var scoreValue:SKLabelNode!
    var highScoreOnStart:SKLabelNode!
    
    var faceMeshGuide:SKSpriteNode!
    
    var powerup1Space:SKSpriteNode!
    var powerup2Space:SKSpriteNode!
    
    var startTime = TimeInterval()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var hasNewHighScore = false
    
    override func didMove(to view: SKView) {
        setupInterface()
        view.isMultipleTouchEnabled = true
    }
    
    func setupInterface() {
        addTimer()
        addInstructions()
        addHighScoreOnStartLabel()
//        addPause()
        addPowerup1Space()
        addPowerup2Space()
        addFaceMeshGuide()
    }
    
    func addFaceMeshGuide(){
        faceMeshGuide = SKSpriteNode(imageNamed: "faceMesh")
        faceMeshGuide.size = CGSize(width: 250, height: 250)
        faceMeshGuide.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        addChild(faceMeshGuide)
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
        
        let parsedTime = TimeInterval(appDelegate.highScore).parseTime()
        let strMinutes = String(format: "%02d", parsedTime.0)
        let strSeconds = String(format: "%02d", parsedTime.1)
        let strFraction = String(format: "%02d", parsedTime.2)

        highScoreOnStart.text = "highscore: \(strMinutes).\(strSeconds).\(strFraction)"
        highScoreOnStart.fontColor = UIColor(netHex: 0x5C5854)
        highScoreOnStart.fontSize = 20
        addChild(highScoreOnStart)
    }
    
    func addPause(){
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSize(width: 200, height: 200)
        pauseButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        addChild(pauseButton)
    }
    
    func addTimer(){
        timer = SKSpriteNode(color: UIColor.green, size: CGSize(width: UIScreen.main.bounds.width, height: self.frame.height * 0.40))
        timer.alpha = 0.5
        timer.anchorPoint.x = 0
        timer.position = CGPoint(x: 0, y: self.frame.height)
        addChild(timer)
    }
    
    func addPowerup1Space(){
        powerup1Space = SKSpriteNode(imageNamed: "powerup1")
        powerup1Space.size = CGSize(width: 100, height: 100)
        powerup1Space.position = CGPoint(x: self.frame.width * 1 / 4, y: 100)
        addChild(powerup1Space)
    }

    func addPowerup2Space(){
        powerup2Space = SKSpriteNode(imageNamed: "powerup2")
        powerup2Space.size = CGSize(width: 100, height: 100)
        powerup2Space.position = CGPoint(x: self.frame.width * 3 / 4, y: 100)
        addChild(powerup2Space)
    }

    func updateScore() {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        let elapsedTime: TimeInterval = currentTime - startTime
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
    
    func updateTimer(_ rate: Double) {
        timer.xScale += CGFloat(rate)
        if timer.xScale > 1.0 { timer.xScale = 1.0 }
        timer.color = updateTimerColor(timer.xScale)
        
        updateScore()
    }
    
    func updateTimerColor(_ xScale:CGFloat) -> UIColor {
        switch xScale {
        case  _ where xScale > 0.5 :
            return UIColor.green//UIColor(netHex:0x7ED321) //green
        case  _ where xScale > 0.25 :
            return UIColor(netHex:0xF8E71C) //yellow
        default:
            return UIColor(netHex:0xD0021B) //red
        }
    }
    
    func getTimer() -> Double {
        return Double(timer.xScale)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if powerup1Space.contains(location) { startPowerUp(.slomo) }
            if powerup2Space.contains(location) { startPowerUp(.catchall) }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if powerup1Space.contains(location) { endPowerUp(.slomo) }
            if powerup2Space.contains(location) { endPowerUp(.catchall) }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if powerup1Space.contains(location) { endPowerUp(.slomo) }
            if powerup2Space.contains(location) { endPowerUp(.catchall) }
        }
    }
    
    func startPowerUp(_ type:PowerUp) {
        print("start \(type)")
        switch type {
        case .slomo:
            gameSpeed = 0.5
        case .catchall:
            gameSpeed = 0.25
        default:
            gameSpeed = 1
        }

    }
    
    func endPowerUp(_ type:PowerUp) {
        print("end \(type)")
        switch type {
        case .slomo:
            gameSpeed = 1
        case .catchall:
            gameSpeed = 1
        default:
            gameSpeed = 1
        }
    }
    
    func getSpeed() -> CGFloat {
        return gameSpeed
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
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func loadPostGame() {
        uikitDelegate?.loadPostGame()
    }
    
    func startGamePlay() {
        uikitDelegate?.startPlaying()
    }
}
