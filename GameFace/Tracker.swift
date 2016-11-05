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
    private init() {}

    func loginRequest() {
//        recordPlayFabLogin()
    }
    
    func saveHighScore() {
        
    }
    
    func startedPlaying() {
        
    }
        
    func tappedPlayAgain() {
        
    }

    func tappedShare() {
        
    }
    
    func recordPlayFabLogin(){
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
    
    func recordPlayFabUserData(updatedData:[NSObject:AnyObject]!) {
        let userDataRequest = UpdateUserDataRequest()
        userDataRequest.Data = updatedData
        PlayFabClientAPI.GetInstance().UpdateUserData(userDataRequest,
            success: { (response:UpdateUserDataResult!, userData:NSObject!) in
                print("player updated: \(userData)")
            }, failure: { (error:PlayFabError!, userData:NSObject!) in
                print("player failed to update: \(error.errorCode) \n \(error.errorDetails)")
            }, withUserData: nil
        )
    }
    
    func recordPlayFabPlayerEvent(event:PlayerEvent, eventData:[NSObject:AnyObject]!){
        let eventName = event.rawValue
        let eventRequest = WriteClientPlayerEventRequest()
        eventRequest.EventName = eventName
        eventRequest.Body = eventData
        PlayFabClientAPI.GetInstance().WritePlayerEvent(eventRequest,
            success: { (response:WriteEventResponse!, userData:NSObject!) in
                print("event recorded: \(eventName)")
            },
            failure: { (error:PlayFabError!, useData:NSObject!) in
                print("event failed: \(eventName)")
            },
            withUserData: nil
        )
    }
}
