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
    private init() {} //This prevents others from using the default '()' initializer

    func loginRequest() {
        let loginRequest:LoginWithCustomIDRequest = LoginWithCustomIDRequest()
        loginRequest.CustomId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        loginRequest.CreateAccount = true
        
        PlayFabClientAPI.GetInstance().LoginWithCustomID(loginRequest,
                                                         success: { (result:LoginResult!, userData:NSObject!) in
                                                            print("success: \n \(result.PlayFabId) \n \(result.LastLoginTime) \n \(userData)")
        }, failure: { (error:PlayFabError!, userData:NSObject!) in
            print("error: \n \(error.errorCode) \(error.errorMessage) \n \(error.errorDetails) \n \(userData)")
        }, withUserData: nil
        )
    }

}
