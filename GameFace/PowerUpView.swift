//
//  PowerUpView.swift
//  GameFace
//
//  Created by Stanley Chiang on 12/31/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class PowerUpView: UIView {
    
    var spacer:UIView = UIView()
    var powerUpManagerButton:UIButton = UIButton()
    
    var powerUpSize:CGSize!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let size = frame.size
        let inset:CGFloat = 30
        powerUpSize = CGSize(width: size.width / 4, height: size.width / 4)
        
        let shades = UIImage(named: "redo")
        powerUpManagerButton.translatesAutoresizingMaskIntoConstraints = false
        powerUpManagerButton.backgroundColor = UIColor.orange
        powerUpManagerButton.layer.borderColor = UIColor.black.cgColor
        powerUpManagerButton.layer.borderWidth = 3
        powerUpManagerButton.setImage(shades, for: UIControlState.normal)
        powerUpManagerButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        powerUpManagerButton.addTarget(self, action: #selector(loadPowerUpManagerView(sender:)), for: UIControlEvents.touchUpInside)
        addSubview(powerUpManagerButton)
        
    }
    
    override func layoutSubviews() {
        powerUpManagerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        powerUpManagerButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        powerUpManagerButton.widthAnchor.constraint(equalToConstant: powerUpSize.width).isActive = true
        powerUpManagerButton.heightAnchor.constraint(equalTo: powerUpManagerButton.widthAnchor).isActive = true
        
        powerUpManagerButton.layer.cornerRadius = powerUpManagerButton.frame.size.width / 2
        powerUpManagerButton.layoutIfNeeded()
    }
    
    func loadPowerUpManagerView(sender: UIButton) {
        print("load manager")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
