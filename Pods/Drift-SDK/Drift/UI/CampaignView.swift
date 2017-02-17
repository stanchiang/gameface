//
//  CampaignView.swift
//  Drift
//
//  Created by Eoin O'Connell on 03/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

///Abstract class for campaigns to subclass
class CampaignView: UIView {
    
    weak var delegate: PresentationManagerDelegate?
    
    func showOnWindow(_ window: UIWindow) {}
    
    func hideFromWindow() {}
    
    func updateOtherCampaignCount(_ count: Int){}
}
