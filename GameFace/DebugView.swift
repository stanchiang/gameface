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
        
        let smsButton:UIButton = UIButton(frame: CGRectMake(0,400,300,100))
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
        print(Double(textField.text!)!)
        let stepper = (subviews[indexOfStepper] as! UIStepper)
        stepper.value = Double(textField.text!)!
    }
    
    func getGameStartMouthDist() -> Float {
        for view in subviews {
            if view is UIStepper && view.tag == 0 {
                return Float((view as! UIStepper).value)
            }
        }
        return 25.0
    }
    
    func getOpenMouthDrainRate() -> Double {
        for view in subviews {
            if view is UIStepper && view.tag == 1 {
                return (view as! UIStepper).value
            }
        }
        return 4.0
    }
    
    
    func getClosedMouthDrainRate() -> Double {
        for view in subviews {
            if view is UIStepper && view.tag == 2 {
                return (view as! UIStepper).value
            }
        }
        return 1.0
    }
    
    func getGameScoreBonus() -> Double {
        for view in subviews {
            if view is UIStepper && view.tag == 3 {
                return (view as! UIStepper).value
            }
        }
        return 2.0

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
        dict.updateValue(["tag":1,"value":4,"min":0,"max":20,"step":1], forKey: "open mouth drain rate")
        dict.updateValue(["tag":2,"value":1,"min":0,"max":20,"step":1], forKey: "closed mouth drain rate")
        dict.updateValue(["tag":3,"value":2,"min":0,"max":10,"step":1], forKey: "game score bonus")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

