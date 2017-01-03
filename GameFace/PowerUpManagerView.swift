//
//  PowerUpManagerView.swift
//  GameFace
//
//  Created by Stanley Chiang on 12/31/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class PowerUpManagerView: UIView {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let inset:CGFloat = 30
    
    var creditsImage:UIImageView = UIImageView()
    var creditsValue:UILabel = UILabel()
    var creditsLabel:UILabel = UILabel()
    var IAPButton:UIButton = UIButton()
    var backButton:UIButton = UIButton()
    var powerUpContainer:UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.blurView()

        creditsImage = UIImageView(image: UIImage(named: "bolt"))
        creditsImage.translatesAutoresizingMaskIntoConstraints = false
        creditsImage.contentMode = .scaleAspectFit
        addSubview(creditsImage)
        
        creditsValue.translatesAutoresizingMaskIntoConstraints = false
        creditsValue.text = "\(appDelegate.credits)"
        addSubview(creditsValue)
        
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.text = "credits"
        addSubview(creditsLabel)
        
        IAPButton.translatesAutoresizingMaskIntoConstraints = false
        IAPButton.backgroundColor = UIColor.green
        IAPButton.addTarget(self, action: #selector(IAPButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        addSubview(IAPButton)
        
        let backImage = UIImage(named: "redo")
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor.blue
        backButton.setImage(backImage, for: UIControlState.normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: UIControlEvents.touchUpInside)
        addSubview(backButton)
        
    }
    
    override func layoutSubviews() {
        creditsImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        creditsImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        creditsImage.widthAnchor.constraint(equalToConstant: self.frame.size.width / 4).isActive = true
        creditsImage.heightAnchor.constraint(equalToConstant: self.frame.size.width / 4).isActive = true
        
        creditsValue.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        creditsValue.topAnchor.constraint(equalTo: creditsImage.bottomAnchor).isActive = true
        
        creditsLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        creditsLabel.topAnchor.constraint(equalTo: creditsValue.bottomAnchor).isActive = true
        
        IAPButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        IAPButton.topAnchor.constraint(equalTo: creditsLabel.bottomAnchor).isActive = true
        IAPButton.widthAnchor.constraint(equalToConstant: self.frame.size.width / 4).isActive = true
        IAPButton.heightAnchor.constraint(equalToConstant: self.frame.size.width / 4).isActive = true
        IAPButton.layer.cornerRadius = IAPButton.frame.size.width / 2
        IAPButton.layoutIfNeeded()
        
        backButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: IAPButton.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: self.frame.size.width / 4).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: self.frame.size.width / 4).isActive = true
        backButton.layer.cornerRadius = backButton.frame.size.width / 2
        backButton.layoutIfNeeded()
    }
    
    func IAPButtonTapped(sender: UIButton) {
        print("iap button tapped")
    }
    
    func backAction(sender: UIButton){
        print("back button tapped")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
