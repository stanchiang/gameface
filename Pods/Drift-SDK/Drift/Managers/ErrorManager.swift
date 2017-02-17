//
//  ErrorManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 23/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


enum DriftError: Error {
    case apiFailure
    case authFailure
    case embedFailure
    case dataCreationFailure
}


class LoggerManager {
    
    class func didRecieveError(_ error: Error) {
        if DriftManager.sharedInstance.debug {
            print(error)
        }
    }
    
    class func log(_ text: String) {
        if DriftManager.sharedInstance.debug {
            print("🚀🚀\(text)🚀🚀")
        }
    }
}
