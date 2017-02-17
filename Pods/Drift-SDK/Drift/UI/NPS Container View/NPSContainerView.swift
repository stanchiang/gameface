//
//  NPSContainerView.swift
//  Drift
//
//  Created by Eoin O'Connell on 27/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

///Methods subviews can call on container
protocol ContainerSubViewDelegate: class {
    func subViewNeedsDismiss(_ campaign: Campaign, response: CampaignResponse)
    func subViewNeedsToPresent(_ campaign: Campaign, view: ContainerSubView)
}

///Abstract class used to ensure all container subviews have delegate back to container view and a campaign
class ContainerSubView:UIView {
    weak var delegate:ContainerSubViewDelegate?
    var campaign:Campaign?
}

///Container view for NPS
class NPSContainerView: CampaignView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewCenterYConstraint: NSLayoutConstraint!
    var campaign: Campaign!
    var viewStack: [ContainerWrapper] = []
    
    ///Wrapper on Subviews to hold reference to top and bottom constraints
    class ContainerWrapper {
        var view: ContainerSubView
        var topConstraint: NSLayoutConstraint
        var bottomConstraint: NSLayoutConstraint
        
        init(view: ContainerSubView, topConstraint: NSLayoutConstraint, bottomConstraint: NSLayoutConstraint){
            self.view = view
            self.topConstraint = topConstraint
            self.bottomConstraint = bottomConstraint
        }
    }
    
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(NPSContainerView.keyboardShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(NPSContainerView.keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    
    override func awakeFromNib() {
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 5
        containerView.isHidden = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    ///Animate In initial View inside container
    func popUpContainer(initialView: ContainerSubView){
        
        initialView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(initialView)

        containerView.addConstraint(NSLayoutConstraint(item: initialView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: initialView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0))
        
        let top = NSLayoutConstraint(item: initialView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: initialView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0)
        containerView.addConstraint(top)
        containerView.addConstraint(bottom)
        
        initialView.delegate = self
        viewStack = [ContainerWrapper(view: initialView, topConstraint: top, bottomConstraint: bottom)]
        
        let background = DriftDataStore.sharedInstance.generateBackgroundColor()
        containerView.backgroundColor = background
        
        containerView.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        containerView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }, completion: nil)
    }
    
    ///Replace current top view with next view
    func replaceTopView(_ view: ContainerSubView) {

        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        containerView.addSubview(view)
        
        containerView.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0))
        
        let top = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -containerView.frame.size.height)
        let bottom = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: -containerView.frame.size.height)
        containerView.addConstraint(top)
        containerView.addConstraint(bottom)
        
        layoutIfNeeded()
        
        if let currentContainer = viewStack.last {
            animateOff(currentContainer)
        }
        
        view.delegate = self
        let newContainer = ContainerWrapper(view: view, topConstraint: top, bottomConstraint: bottom)
        viewStack.append(newContainer)
        
        animateOn(newContainer)
    }
   
    ///Animate off view
    func animateOff(_ containerWrapper: ContainerWrapper) {
        
        containerWrapper.topConstraint.constant = containerView.frame.size.height
        containerWrapper.bottomConstraint.constant = containerView.frame.size.height
        setNeedsLayout()
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: { (success) -> Void in
            if success {
                containerWrapper.view.isHidden = true
            }
        }) 
        
    }
    
    
    ///Animate on a given view
    func animateOn(_ containerWrapper: ContainerWrapper) {
        
        containerWrapper.view.isHidden = false
        containerWrapper.topConstraint.constant = 0
        containerWrapper.bottomConstraint.constant = 0
        setNeedsLayout()
        UIView.animate(withDuration: 0.7, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: nil)
    }

    @IBAction func didTapBackground() {
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: .nps(.dismissed))
    }
    
    
    ///Overrides
    ///Show NPS Container on window
    override func showOnWindow(_ window: UIWindow) {
        window.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: window, attribute: .leading, multiplier: 1.0, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1.0, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        window.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 1.0, constant: 0))
        
    }
    
    ///Hide Container from view
    override func hideFromWindow() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.alpha = 0
            }, completion: { (success) in
                if success {
                    self.removeFromSuperview()
                }
        })
    }
    
    ///Keyboard
    func keyboardShown(_ notification: Notification) {
        
        if let size = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let height = min(size.height, size.width)
            let bottomContainerHeight = frame.size.height - (containerView.frame.size.height + containerView.frame.origin.y)
            
            if bottomContainerHeight < height {
                containerViewCenterYConstraint.constant = -(height - bottomContainerHeight + 30)
                UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.layoutIfNeeded()
                    }, completion: nil)
            }
        }
        
    }
    
    func keyboardHidden(_ notification: Notification) {
        containerViewCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: nil)
    }
}

extension NPSContainerView: ContainerSubViewDelegate{
    
    func subViewNeedsDismiss(_ campaign: Campaign, response: CampaignResponse){
        delegate?.campaignDidFinishWithResponse(self, campaign: campaign, response: response)
    }
    
    
    func subViewNeedsToPresent(_ campaign: Campaign, view: ContainerSubView) {
        self.campaign = campaign
        view.campaign = campaign
        replaceTopView(view)
    }
    
}
