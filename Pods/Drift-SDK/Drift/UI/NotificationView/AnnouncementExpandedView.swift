//
//  AnnouncementExpandedView.swift
//  Drift
//
//  Created by Eoin O'Connell on 19/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class AnnouncementExpandedView: CampaignView, UIScrollViewDelegate {
    var campaign: Campaign! {
        didSet{
            setupForCampaign()
        }
    }
    
    struct ConstraintChanges {
        
        fileprivate let topConstraint: (reg: CGFloat, compact: CGFloat) = (120, 10)
        fileprivate let bottomConstraint: (reg: CGFloat, compact: CGFloat) = (120, 10)
        
        var bottomConstant: CGFloat {
            if traitCollection.verticalSizeClass == .compact {
                return bottomConstraint.compact
            }else{
                return bottomConstraint.reg
            }
        }
        
        var topConstant: CGFloat {
            if traitCollection.verticalSizeClass == .compact {
                return topConstraint.compact
            }else{
                return topConstraint.reg
            }
        }
        
        var traitCollection: UITraitCollection
        init(traits: UITraitCollection) {
            self.traitCollection = traits
        }
        
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var campaignCreatorImageView: UIImageView!
    @IBOutlet weak var campaignCreatorNameLabel: UILabel! {
        didSet{
            campaignCreatorNameLabel.text = ""
        }
    }
    @IBOutlet weak var campaignCreatorCompanyLabel: UILabel! {
        didSet {
            campaignCreatorCompanyLabel.text = ""
        }
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var announcementTitleLabel: UILabel!
    @IBOutlet weak var announcementInfoTextView: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    
    let gradient = CAGradientLayer()
    
    @IBOutlet weak var ctaButton: UIButton! {
        didSet{
            ctaButton.layer.cornerRadius = 4
            ctaButton.clipsToBounds = true
            let background = DriftDataStore.sharedInstance.generateBackgroundColor()
            let foreground = DriftDataStore.sharedInstance.generateForegroundColor()
            ctaButton.backgroundColor = background
            ctaButton.setTitleColor(foreground, for: UIControlState())
        }
    }
    @IBOutlet weak var ctaHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    
    
    override func showOnWindow(_ window: UIWindow) {
        window.addSubview(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AnnouncementExpandedView.didRotate), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: window, attribute: .leading, multiplier: 1.0, constant: 0)
        window.addConstraint(leading)
        let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1.0, constant: 0)
        window.addConstraint(trailing)
        
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 1.0, constant: 0))

        containerView.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        window.layoutIfNeeded()
        
        campaignCreatorNameLabel.textColor = ColorPalette.grayColor
        campaignCreatorCompanyLabel.textColor = ColorPalette.grayColor
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 4
        
        campaignCreatorImageView.clipsToBounds = true
        campaignCreatorImageView.layer.cornerRadius = 3
        campaignCreatorImageView.contentMode = .scaleAspectFill
        
        scrollView.delegate = self
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        
        gradient.frame = CGRect(x: 0, y: 0, width: scrollViewContainer.frame.width, height: scrollViewContainer.frame.height)
        
        if scrollView.contentSize.height > scrollView.frame.size.height{
            gradient.colors = [
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.clear.cgColor
            ]
            scrollView.isScrollEnabled = true
        }else{
            gradient.colors = [
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor
            ]
            scrollView.isScrollEnabled = false
        }
        
        gradient.locations = [0, 0.2, 0.8, 1.0]
        scrollViewContainer.layer.mask = gradient
        
        closeButton.tintColor = ColorPalette.grayColor
        
        
        window.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.4, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            window.layoutIfNeeded()
            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }, completion: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }

    func didRotate(){
        let constants = ConstraintChanges(traits: traitCollection)
        containerTopConstraint.constant = constants.topConstant
        containerBottomConstraint.constant = constants.bottomConstant
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.gradient.frame = CGRect(x: 0, y: 0, width: self.scrollViewContainer.frame.width, height: self.scrollViewContainer.frame.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height{
            gradient.colors = [
                UIColor.clear.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor
            ]
        }else if scrollView.contentOffset.y > 0{
            gradient.colors = [
                UIColor.clear.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.clear.cgColor
            ]
        }else if scrollView.contentOffset.y <= 0{
            gradient.colors = [
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.white.cgColor,
                UIColor.clear.cgColor
            ]
        }
    }
    
    func setupForCampaign() {
        
        if let cta = campaign.announcementAttributes?.cta {
            if let copy = cta.copy {
                ctaButton.setTitle(copy, for: UIControlState())
            }else{
                ctaButton.setTitle("Find Out More", for: UIControlState())
            }
        }else{
            ctaButton.isHidden = true
            ctaHeightConstraint.constant = 0
            containerView.setNeedsLayout()
            containerView.layoutIfNeeded()
        }
        
        if let announcement = campaign.announcementAttributes {
            announcementTitleLabel.text = announcement.title ?? ""
            
            do {
                let htmlStringData = (campaign.bodyText ?? "").data(using: String.Encoding.utf8)!
                let attributedHTMLString = try NSMutableAttributedString(data: htmlStringData, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
                announcementInfoTextView.text = attributedHTMLString.string
            } catch {
                announcementInfoTextView.text = campaign.bodyText ?? ""
            }
            
            announcementInfoTextView.font = UIFont(name: "Avenir", size: 16)
            
        }
    
        if let organizerId = campaign.authorId {
            
            APIManager.getUser(organizerId, orgId: DriftDataStore.sharedInstance.embed!.orgId, authToken: DriftDataStore.sharedInstance.auth!.accessToken, completion: { (result) -> () in
                switch result {
                case .success(let users):
                    if let avatar = users.first?.avatarURL {
                        self.campaignCreatorImageView.af_setImage(withURL: URL.init(string:avatar)!)
                    }
                    if let creatorName = users.first?.name {
                        self.campaignCreatorNameLabel.text = creatorName
                    }
                case .failure(_):
                    ()
                }
            })
        }
    
        campaignCreatorCompanyLabel.text = DriftDataStore.sharedInstance.embed?.organizationName ?? ""
        layoutIfNeeded()
    }
    
    @IBAction func ctaButtonPressed(_ sender: AnyObject) {
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: .announcement(.Clicked))
        
        if let cta = campaign?.announcementAttributes?.cta {
            
            switch cta.ctaType {
            case .some(.ChatResponse):
                PresentationManager.sharedInstance.showNewConversationVC(campaign.authorId)
            case .some(.LinkToURL):
                if let url = cta.urlLink {
                    presentURL(url as URL)
                }
            default:
                LoggerManager.log("No CTA")
            }
            
        }else{
            //Read
            LoggerManager.log("No CTA")
        }
    }
    
    func presentURL(_ url: URL) {
        
        if #available(iOS 9.0, *) {
            if let topVC = TopController.viewController(), let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                let safari = SFSafariViewController(url: url)
                topVC.present(safari, animated: true, completion: nil)
                return
            }
        }else{
            UIApplication.shared.openURL(url)
        }
    }

    
    @IBAction func pressedClose(_ sender: AnyObject) {
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: .announcement(.Dismissed))
    }
    
    override func hideFromWindow() {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.containerView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            self.backgroundColor = UIColor.clear
        }, completion: { (success) -> Void in
            self.alpha = 0
            if success {
                self.removeFromSuperview()
            }
        }) 
    }
}
