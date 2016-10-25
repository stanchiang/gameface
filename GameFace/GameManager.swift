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
    func startRecording()
}

class GameManager: SKScene, GameSceneDelegate {
    weak var managerDelegate:GameManagerDelegate?
    weak var uikitDelegate:UIKitDelegate?
    var instructions:SKLabelNode!
    var scoreLabel: SKLabelNode!
    var scoreShadow: SKLabelNode!
    var pauseButton:SKSpriteNode!
    
    let length:CGFloat = 50
    var timer:SKSpriteNode!
    var scoreTitle:SKLabelNode!
    var scoreValue:SKLabelNode!
    
    var startTime = NSTimeInterval()

    override func didMoveToView(view: SKView) {
        setupInterface()
    }
    
    func setupInterface() {
        addTimer(length)
        addInstructions(length)
    }
    
    func addScoreValue(length:CGFloat) {
        scoreValue = SKLabelNode()
        scoreValue.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.9)
        scoreValue.text = "00.00.00"
        scoreValue.fontColor = UIColor(netHex: 0x5C5854)
        scoreValue.fontName = "San Francisco-Bold"
        scoreValue.fontSize = 40
        addChild(scoreValue)
    }
    
    func addScoreTitle(length:CGFloat){
        scoreTitle = SKLabelNode()
        scoreTitle.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.85)
        scoreTitle.text = "score"
        scoreTitle.fontName = "San Francisco-Medium"
        scoreTitle.fontColor = UIColor(netHex: 0x5C5854)
        addChild(scoreTitle)
    }
    
    func addInstructions(length:CGFloat){
        instructions = SKLabelNode(fontNamed: "San Francisco-Bold")
        instructions.position = CGPoint(x: self.view!.frame.width / 2, y: self.frame.height * 0.9)
        instructions.text = "Open Your Mouth 😮"
        instructions.fontColor = UIColor(netHex: 0x5C5854)
        addChild(instructions)
    }
    
    func addPause(length:CGFloat){
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSizeMake(length, length)
        pauseButton.position = CGPoint(x: self.frame.width - length, y: self.frame.height - length)
        addChild(pauseButton)
    }
    
    func addTimer(length:CGFloat){
        timer = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: UIScreen.mainScreen().bounds.width, height: self.frame.height * 0.40))
        timer.alpha = 0.5
        timer.anchorPoint.x = 0
        timer.position = CGPoint(x: 0, y: self.frame.height)
        addChild(timer)
    }
    
    func updateScore() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        scoreValue.text = "\(strMinutes).\(strSeconds).\(strFraction)"
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
    
    func swapInstructionsWithScore() {
        instructions.removeFromParent()
        
        addScoreTitle(length)
        addScoreValue(length)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func loadPostGame() {
        uikitDelegate?.loadPostGame()
    }
    
    func startRecordingGamePlay() {
        uikitDelegate?.startRecording()
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
