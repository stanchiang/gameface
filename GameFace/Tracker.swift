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

    func appLaunchConfiguration() {
        Segment.sharedInstance.configuration()
    }
    
    func loginRequest() {
        
    }
    
    func saveHighScore() {
        
    }
    
    func startedPlaying() {
        
    }
        
    func tappedPlayAgain() {
        
    }

    func tappedShare() {
        
    }

}
