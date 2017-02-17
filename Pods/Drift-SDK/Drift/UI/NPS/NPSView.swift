//
//  NPSView.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class NPSView: ContainerSubView {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var buttonContainer: UIView!
    
    @IBOutlet weak var separatorBar: UIView!
    @IBOutlet weak var zeroLabel: UILabel!
    @IBOutlet weak var tenLabel: UILabel!
    
    
    @IBOutlet weak var button0: NPSButton!
    @IBOutlet weak var button1: NPSButton!
    @IBOutlet weak var button2: NPSButton!
    @IBOutlet weak var button3: NPSButton!
    @IBOutlet weak var button4: NPSButton!
    @IBOutlet weak var button5: NPSButton!
    @IBOutlet weak var button6: NPSButton!
    @IBOutlet weak var button7: NPSButton!
    @IBOutlet weak var button8: NPSButton!
    @IBOutlet weak var button9: NPSButton!
    @IBOutlet weak var button10: NPSButton!
    
    var buttons: [NPSButton] = []
    
    override var campaign: Campaign? {
        didSet{
            setupForNPS()
        }
    }
    
    var otherCampaigns: [Campaign] = []
    
    func setupForNPS(){
        
        if let npsSurvey = campaign {
            titleLabel.text = npsSurvey.bodyText ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        buttons.append(button0)
        buttons.append(button1)
        buttons.append(button2)
        buttons.append(button3)
        buttons.append(button4)
        buttons.append(button5)
        buttons.append(button6)
        buttons.append(button7)
        buttons.append(button8)
        buttons.append(button9)
        buttons.append(button10)
        
        let foreground = DriftDataStore.sharedInstance.generateForegroundColor()
        
        for button in buttons {
            button.addTarget(self, action: #selector(NPSView.didSelectButton(_:)), for: .touchUpInside)
            button.isHidden = true
            button.titleColor = foreground
            button.backgroundColor = UIColor.clear
            button.borderColor = foreground
        }
        
        closeButton.tintColor = foreground
        titleLabel.textColor = foreground
        separatorBar.backgroundColor = foreground
        zeroLabel.textColor = foreground.alpha(0.7)
        tenLabel.textColor = foreground.alpha(0.7)
        
        animateButtonsIn()
    }
    
    fileprivate func animateButtonsIn(){
    
        for (i, button) in buttons.enumerated() {
            button.transform = CGAffineTransform(scaleX: 0, y: 0)
            button.isHidden = false
            let delay: Double = 0.05 * Double(i)
            UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    func didSelectButton(_ sender: NPSButton){
        
        let index = buttons.index(of: sender) ?? 0
        
        let background = DriftDataStore.sharedInstance.generateBackgroundColor()
        let foreground = DriftDataStore.sharedInstance.generateForegroundColor()
        for (i, button) in buttons.enumerated() {
        
            if i <= index {
                button.titleColor = background
                button.backgroundColor = foreground
                button.borderColor = UIColor.clear
            }else{
                button.titleColor = foreground
                button.backgroundColor = UIColor.clear
                button.borderColor = foreground
            }
        }
        
        if let npsView = NPSCommentView.fromNib() as? NPSCommentView {
            npsView.numericResponse = index
            delegate?.subViewNeedsToPresent(campaign!, view: npsView)
        }
        
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        delegate?.subViewNeedsDismiss(campaign!, response: .nps(.dismissed))
    }
    
}
