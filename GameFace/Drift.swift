//
//  Drift.swift
//  GameFace
//
//  Created by Stanley Chiang on 2/16/17.
//  Copyright © 2017 Stanley Chiang. All rights reserved.
//

import Foundation
import Drift_SDK

class DriftSDK {
    static let sharedInstance = DriftSDK()
    fileprivate init() {}
    
    func configuration() {
        Drift.setup(Constants.driftEmbedID)
        Drift.registerUser("", email: "")
    }
    
    func start() {
        Drift.showConversations()
    }
        
}
