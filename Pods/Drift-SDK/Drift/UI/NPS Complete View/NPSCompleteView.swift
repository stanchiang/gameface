//
//  NPSCompleteView.swift
//  Drift
//
//  Created by Eoin O'Connell on 25/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class NPSCompleteView: ContainerSubView {

    var numericResponse: Int!
    var comment: String!

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonContainer: UIView!
    
    @IBOutlet weak var thankYouLabel: UILabel!
    
    
    override var campaign: Campaign? {
        didSet{
            setupForNPS()
        }
    }
    
    
    func setupForNPS(){
        
        if numericResponse <= 6 {
            //Detractors
            imageView.isHidden = true
            imageHeightConstraint.constant = 20
        }else if numericResponse >= 9 {
            //Promoters
            bottomLabel.isHidden = true
            imageTopConstraint.constant = 60
            imageView.image = UIImage(named: "veryHappyFace", in: Bundle(for: Drift.self), compatibleWith: nil)
        }else{
            //Passive
            imageTopConstraint.constant = 60
            bottomLabel.isHidden = true
            imageView.image = UIImage(named: "happyFace", in: Bundle(for: Drift.self), compatibleWith: nil)
        }
        
        
        let foreground = DriftDataStore.sharedInstance.generateForegroundColor()

        sendButtonContainer.backgroundColor = foreground.alpha(0.1)
        sendButton.setTitleColor(foreground, for: UIControlState())
        thankYouLabel.textColor = foreground
        bottomLabel.textColor = foreground
        imageView.tintColor = foreground

    
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        didFinish()
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        didFinish()
    }
    
    func didFinish() {
        
        var response: CampaignResponse = .nps(.numeric(numericResponse))

        if comment != "" {
            response = .nps(.textAndNumeric(numericResponse, comment))
        }
        
        delegate?.subViewNeedsDismiss(campaign!, response: response)

    }
    
}
