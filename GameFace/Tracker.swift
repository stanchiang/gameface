//
//  Tracker.swift
//  GameFace
//
//  Created by Stanley Chiang on 11/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import Foundation

class Tracker {
    static let sharedInstance = Tracker()
    fileprivate init() {}

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    func appLaunchConfiguration() {
        Segment.sharedInstance.configuration()
        
        let hasUUIDIdentified = appDelegate.userDefaults.bool(forKey: "UUIDIdentified")
        if !hasUUIDIdentified {
            Segment.sharedInstance.userSetup()
            appDelegate.userDefaults.set(true, forKey: "UUIDIdentified")
        }
    }
    
    func record(event: Event) {
        Segment.sharedInstance.recordEvent(event: event)
    }
    
}
