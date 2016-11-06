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
        loginRequest.customId = UIDevice.current.identifierForVendor?.uuidString
        loginRequest.createAccount = true
        
        PlayFabClientAPI.getInstance().login(withCustomID: loginRequest,
             success: { (result:LoginResult!, userData:NSObject!) in
                print("success: \n \(result.playFabId) \n \(result.lastLoginTime) \n \(userData)")
            } as! LoginWithCustomIDCallback,
             failure: { (error:PlayFabError!, userData:NSObject!) in
                print("error: \n \(error.errorCode) \(error.errorMessage) \n \(error.errorDetails) \n \(userData)")
            } as! ErrorCallback
            , withUserData: nil
        )
    }
    
    func recordPlayFabUserData(_ updatedData:[AnyHashable: Any]!) {
        let userDataRequest = UpdateUserDataRequest()
        userDataRequest.data = updatedData
        PlayFabClientAPI.getInstance().updateUserData(userDataRequest,
            success: { (response:UpdateUserDataResult!, userData:NSObject!) in
                print("player updated: \(userData)")
            } as! UpdateUserDataCallback,
            failure: { (error:PlayFabError!, userData:NSObject!) in
                print("player failed to update: \(error.errorCode) \n \(error.errorDetails)")
            } as! ErrorCallback,
            withUserData: nil
        )
    }
    
    func recordPlayFabPlayerEvent(_ event:PlayerEvent, eventData:[AnyHashable: Any]!){
        let eventName = event.rawValue
        let eventRequest = WriteClientPlayerEventRequest()
        eventRequest.eventName = eventName
        eventRequest.body = eventData
        PlayFabClientAPI.getInstance().writePlayerEvent(eventRequest,
            success: { (response:WriteEventResponse!, userData:NSObject!) in
                print("event recorded: \(eventName)")
            } as! WritePlayerEventCallback,
            failure: { (error:PlayFabError!, userData:NSObject!) in
                print("event failed: \(eventName)")
            } as! ErrorCallback,
            withUserData: nil
        )
    }
}
