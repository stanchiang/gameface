//
//  DebugView.swift
//  GameFace
//
//  Created by Stanley Chiang on 10/14/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MessageUI

class DebugView: UIView, UITextFieldDelegate, GameVarDelegate, MFMessageComposeViewControllerDelegate {

    var dict = [String:[String:Double]]()
    var prevView:UIView!
    let spacer:CGFloat = 15
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.cyanColor()
        
        loadDict()
        
        for option in dict {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = option.0
            addSubview(label)
            
            let input = UITextField()
            input.translatesAutoresizingMaskIntoConstraints = false
            input.delegate = self
            input.keyboardType = UIKeyboardType.DecimalPad
            input.backgroundColor = UIColor.whiteColor()
            input.text = "\(option.1["value"]!)"
            addSubview(input)
            
            let stepper = UIStepper()
            stepper.translatesAutoresizingMaskIntoConstraints = false
            stepper.tag = Int(option.1["tag"]!)
            stepper.value = option.1["value"]!
            stepper.minimumValue = option.1["min"]!
            stepper.maximumValue = option.1["max"]!
            stepper.stepValue = option.1["step"]!
            
            stepper.continuous = true
            stepper.autorepeat = true
            stepper.wraps = true
            addSubview(stepper)
            
            stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), forControlEvents: .ValueChanged)
            
        }
        
        let smsButton:UIButton = UIButton(frame: CGRectMake(0,500,300,100))
        smsButton.addTarget(self, action: #selector(sendText(_:)), forControlEvents: .TouchUpInside)
        smsButton.setTitle("report config", forState: .Normal)
        self.addSubview(smsButton)
        
    }
    
    func sendText(sender:UIButton) {
        var bodyText = "config: "
        for view in subviews {
            if view is UIStepper {
                bodyText += "(\((view as! UIStepper).tag), \((view as! UIStepper).value)) "
            }
        }

        let messageVC = MFMessageComposeViewController()
        messageVC.body = bodyText
        messageVC.recipients = ["3143230873"]
        messageVC.messageComposeDelegate = self;
        
        (window?.rootViewController as! GameGallery).presentViewController(messageVC, animated: true, completion: nil)
        
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stepperValueChanged(sender:UIStepper!) {
        let indexOfInput = subviews.indexOf(sender)! - 1
        (subviews[indexOfInput] as! UITextField).text = "\(sender.value)"
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let indexOfStepper = subviews.indexOf(textField)! + 1
        //print(Double(textField.text!)!)
        let stepper = (subviews[indexOfStepper] as! UIStepper)
        stepper.value = Double(textField.text!)!
    }
    
    func getGameStartMouthDist() -> Float {
        if let value = checkStepperWithTagId(0) {
            return Float(value)
        } else {
            return 25.0
        }
    }
    
    func getOpenMouthDrainRate() -> Double {
        if let value = checkStepperWithTagId(1) {
            return value
        } else {
            return 4.0
        }
    }
    
    
    func getClosedMouthDrainRate() -> Double {
        if let value = checkStepperWithTagId(2) {
            return value
        } else {
            return 1.0
        }
    }
    
    func getGameScoreBonus() -> Double {
        if let value = checkStepperWithTagId(3) {
            return value
        } else {
            return 2.0
        }
    }
    
    func getAdjustedPPI() -> CGFloat {
        switch UIScreen.mainScreen().bounds.height {
        case 480:
            return 0
        case 568.0:
            return 1.0
        case 667.0:
            return 12.5
        case 736.0:
            return 21.5
        default:
            return 21.5
        }
    }
    
    func getSpawnRate() -> Double {
        if let value = checkStepperWithTagId(5) {
            return value
        } else {
            return 0.5
        }
    }

    func getSpriteInitialSpeed() -> Double {
        if let value = checkStepperWithTagId(6) {
            return value
        } else {
            return 1
        }
    }
    
    func getSpriteSize() -> Double {
        if let value = checkStepperWithTagId(7) {
            return value
        } else {
            return 50
        }
    }
    
    func getSpriteEndRange() -> Double {
        if let value = checkStepperWithTagId(8) {
            if value == 0 {
                return value + 0.01
            }else {
                return value
            }
        } else {
            return 3
        }
    }
    
    func getWillRecordGame() -> Bool {
        if let value = checkStepperWithTagId(9) {
            if value > 0 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func getVideoLength() -> Double {
        if let value = checkStepperWithTagId(10) {
            return value
        } else {
            return 5
        }
    }
    
    func getWillAddBombs() -> Bool {
        if let value = checkStepperWithTagId(11) {
            if value > 0 && appDelegate.currentScore > 6 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func getWillShowFaceDetect() -> Bool {
        if let value = checkStepperWithTagId(12) {
            if value > 0 && appDelegate.gameState != .inPlay {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func checkStepperWithTagId(tag:Int) -> Double? {
        for view in subviews {
            if view is UIStepper && view.tag == tag {
                return (view as! UIStepper).value
            }
        }
        return nil
    }
    
    func setDelegate(scene:GameScene) {
        scene.gameVarDelegate = self
    }
    
    override func layoutSubviews() {
        for (index, view) in subviews.enumerate() {
            if view is UILabel {
                view.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
                if index == 0 {
                    view.topAnchor.constraintEqualToAnchor(topAnchor, constant: spacer).active = true
                }else {
                    view.topAnchor.constraintEqualToAnchor(prevView.bottomAnchor, constant: spacer).active = true
                }
                prevView = view
            }
            
            if view is UITextField {
                view.leadingAnchor.constraintEqualToAnchor(prevView.trailingAnchor, constant: spacer).active = true
                view.centerYAnchor.constraintEqualToAnchor(prevView.centerYAnchor).active = true
                
                prevView = view
            }
            
            if view is UIStepper {
                view.leadingAnchor.constraintEqualToAnchor(prevView.trailingAnchor, constant: spacer).active = true
                view.centerYAnchor.constraintEqualToAnchor(prevView.centerYAnchor).active = true
            }
        }
    }
    
    func loadDict() {
        dict.updateValue(["tag":0,"value":25,"min":0,"max":50,"step":1], forKey: "start game mouth open distance")
        dict.updateValue(["tag":1,"value":3,"min":0,"max":20,"step":1], forKey: "open mouth drain rate")
        dict.updateValue(["tag":2,"value":1,"min":0,"max":20,"step":1], forKey: "closed mouth drain rate")
        dict.updateValue(["tag":3,"value":2,"min":0,"max":10,"step":1], forKey: "game score bonus")
        dict.updateValue(["tag":4,"value":21.5,"min":-30,"max":30,"step":0.5], forKey: "adjustedPPI")
        dict.updateValue(["tag":5,"value":0.5,"min":0,"max":3,"step":0.1], forKey: "object spawn rate")
        dict.updateValue(["tag":6,"value":1.3,"min":0,"max":3,"step":0.1], forKey: "sprite initial speed")
        dict.updateValue(["tag":7,"value":50,"min":0,"max":200,"step":10], forKey: "sprite size")
        dict.updateValue(["tag":8,"value":3,"min":0,"max":10,"step":0.5], forKey: "sprite end range")
        dict.updateValue(["tag":9,"value":1,"min":0,"max":1,"step":1], forKey: "record game")
        dict.updateValue(["tag":10,"value":5,"min":1,"max":10,"step":1], forKey: "video length")
        dict.updateValue(["tag":11,"value":1,"min":0,"max":1,"step":1], forKey: "enable bombs")
        dict.updateValue(["tag":12,"value":1,"min":0,"max":1,"step":1], forKey: "show face detect")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
