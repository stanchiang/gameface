//
//  NotificationView.swift
//  Drift
//
//  Created by Eoin O'Connell on 26/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import SafariServices

class AnnouncementView: CampaignView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var notificationContainer: UIView!
    @IBOutlet weak var notificationCountlabel: UILabel!
    @IBOutlet weak var bottomButtonColourView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    
    var bottomConstraint: NSLayoutConstraint!
    
    var campaign: Campaign! {
        didSet{
            setUpForCampaign()
        }
    }
    var otherCampaigns: [Campaign] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 4
        userImageView.contentMode = .scaleAspectFill
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 5
        notificationContainer.isHidden = true
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2
        shadowView.layer.cornerRadius = 6
    }
    
    func setUpForCampaign() {
        let background = DriftDataStore.sharedInstance.generateBackgroundColor()
        let foreground = DriftDataStore.sharedInstance.generateForegroundColor()

        bottomButtonColourView.backgroundColor = background
        dismissButton.setTitleColor(foreground, for: UIControlState())
        openButton.setTitleColor(foreground, for: UIControlState())
        
        if let announcement = campaign.announcementAttributes {
            titleLabel.text = announcement.title ?? ""
            
            do {
                let htmlStringData = (campaign.bodyText ?? "").data(using: String.Encoding.utf8)!
                let attributedHTMLString = try NSMutableAttributedString(data: htmlStringData, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
                infoLabel.text = attributedHTMLString.string
            } catch {
                infoLabel.text = campaign.bodyText ?? ""
            }
        }

        if let organizerId = campaign.authorId {
            
            APIManager.getUser(organizerId, orgId: DriftDataStore.sharedInstance.embed!.orgId, authToken: DriftDataStore.sharedInstance.auth!.accessToken, completion: { (result) -> () in
                switch result {
                    
                case .success(let users):
                    if let avatar = users.first?.avatarURL {
                        self.userImageView.af_setImage(withURL: URL.init(string:avatar)!)
                    }
                case .failure(let error):
                    LoggerManager.didRecieveError(error)
                }
            })
        }
        
        if !otherCampaigns.isEmpty {
            notificationCountlabel.text = "\(otherCampaigns.count)"
            notificationCountlabel.layer.cornerRadius = notificationCountlabel.frame.size.width / 2
            notificationCountlabel.clipsToBounds = true
            notificationContainer.layer.cornerRadius = notificationContainer.frame.size.width / 2
            notificationContainer.clipsToBounds = true
            notificationContainer.isHidden = false
        }else{
            notificationContainer.isHidden = true
        }
    }
    
    override func showOnWindow(_ window: UIWindow) {
        window.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: window, attribute: .leading, multiplier: 1.0, constant: window.frame.size.width)
        window.addConstraint(leading)
        let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1.0, constant: window.frame.size.width)
        window.addConstraint(trailing)
        
        var bottomConstant: CGFloat = -15.0
        if TopController.hasTabBar() {
            bottomConstant = -65.0
        }
        
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1.0, constant: bottomConstant)
        
        window.addConstraint(bottomConstraint)
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 110.0))
        window.layoutIfNeeded()
        leading.constant = 0
        trailing.constant = 0
        window.setNeedsUpdateConstraints()
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            window.layoutIfNeeded()
        }, completion:nil)
    }
    
    
    
    override func hideFromWindow() {

        bottomConstraint.constant = 130
        setNeedsLayout()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.backgroundColor = UIColor(white: 1, alpha: 0.5)
            self.layoutIfNeeded()
        }, completion: nil)

    }
    
    @IBAction func skipPressed(_ sender: AnyObject) {
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: .announcement(.Dismissed))
    }
    
    @IBAction func readPressed(_ sender: AnyObject) {
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: .announcement(.Opened))
    }
    
        

}
