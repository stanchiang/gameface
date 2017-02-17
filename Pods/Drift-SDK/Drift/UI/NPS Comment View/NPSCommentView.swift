//
//  NPSCommentView.swift
//  Drift
//
//  Created by Eoin O'Connell on 27/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class NPSCommentView: ContainerSubView {


    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var numericResponse: Int!
    
    override var campaign: Campaign? {
        didSet{
            setupForNPS()
        }
    }
    
    
    func setupForNPS(){
        
        if let npsSurvey = campaign {
            thankYouLabel.text = npsSurvey.npsAttributes?.followUpQuestion ?? ""
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let background = DriftDataStore.sharedInstance.generateBackgroundColor()
        let foreground = DriftDataStore.sharedInstance.generateForegroundColor()

        textView.clipsToBounds = true
        textView.layer.cornerRadius = 3.0
        textView.tintColor = background
        sendButtonContainer.backgroundColor = foreground.alpha(0.1)
        sendButton.setTitleColor(foreground, for: UIControlState())
        thankYouLabel.textColor = foreground
        closeButton.tintColor = foreground
        
 
        if background.brightness() < 0.7
        {
            textView.backgroundColor = UIColor.white
        }
        else
        {
            textView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        }

        
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        delegate?.subViewNeedsDismiss(campaign!, response: .nps(.numeric(numericResponse)))
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        let text = textView.text
        if let npsCompleteView = NPSCompleteView.fromNib() as? NPSCompleteView {
            npsCompleteView.numericResponse = numericResponse
            npsCompleteView.comment = text
            delegate?.subViewNeedsToPresent(campaign!, view: npsCompleteView)
        }
        
    }    
}
