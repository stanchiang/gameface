//
//  LayerManager.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import LayerKit

///Deals with everything to do with auth and layer
class LayerManager: NSObject, LYRClientDelegate {
    
    static var sharedInstance: LayerManager = LayerManager()
    var layerClient: LYRClient?
    var userId: Int = -1
    
    ///Completion block passed along auth functions
    var completion: ((_ success: Bool) -> ())?
    //Refresh timer - ensures all syncing is complete before calling presentation Manager - Allows campaigns to stack
    fileprivate var synchronizationTimer: Timer?
    
    fileprivate override init() {
        super.init()
    }
    
    deinit{
        synchronizationTimer?.invalidate()
    }
    
    class func initialize(_ appId: String, userId: Int, completion: @escaping (_ success: Bool) -> ()) {
        
        if sharedInstance.layerClient != nil {
            
            if (sharedInstance.layerClient!.isConnecting){
                return
            }
            
            sharedInstance.userId = userId
            sharedInstance.completion = completion
            sharedInstance.startLayerConection()
            return
        }
        
        let url = URL(string: "layer:///apps/staging/\(appId)")!

        sharedInstance.layerClient = LYRClient(appID: url, delegate: sharedInstance, options: nil)
        sharedInstance.userId = userId
        sharedInstance.completion = completion
        if let connected = sharedInstance.layerClient?.isConnected , connected {
            LoggerManager.log("Layer Logged in - Deauthing")
            sharedInstance.layerClient?.deauthenticate(completion: { (success, error) -> Void in
                if success {
                    LoggerManager.log("Layer Deauth success")
                    sharedInstance.startLayerConection()
                }else{
                    LoggerManager.log("\(error?.localizedDescription)")
                    LoggerManager.log("Layer Deauth Failed")
                    sharedInstance.startLayerConection()
                }
            })
        }else{
            sharedInstance.startLayerConection()
        }   
    }
    
    class func logout(){
        sharedInstance.layerClient?.deauthenticate(completion: { (success, error) -> Void in})
    }
    
    func startLayerConection(){
        LoggerManager.log("Layer Starting connection")
        layerClient?.connect(completion: { (success, error) -> Void in
            if success {
                LoggerManager.log("Connected to Layer")
                self.getNonceFromLayer()
            }else{
                LoggerManager.log("Failed to connect to layer")
            }
        })
    }
    
    func getNonceFromLayer(){
        layerClient?.requestAuthenticationNonce(completion: { (nonce, error) -> Void in
            if let nonce = nonce {
                self.getToken(nonce)
            }else{
                if let nsError = error as? NSError, nsError.code == .some(7005) {
                    self.completion?(true)
                }else{
                    LoggerManager.log("Failed to get nonce: \(error)")
                    self.completion?(false)
                }
                self.completion = nil
            }
        })
    }
    
    func getToken(_ nonce: String) {
        
        APIManager.getLayerAccessToken(nonce, userId: "u:\(userId)") { (result) -> () in
            switch result {
            case .success(let token):
                self.authWithLayer(token)
            case .failure(let error):
                LoggerManager.log("Failed to get nonce: \(error)")
                self.completion?(false)
                self.completion = nil
            }
        }
    }
    
    func authWithLayer(_ token: String) {
        layerClient?.authenticate(withIdentityToken: token, completion: { (authUserId, error) -> Void in
            
            if let authUserId = authUserId {
                LoggerManager.log("Authed with Layer: \(authUserId)")
                self.completion?(true)
                self.completion = nil
            }else{
                if let error = error {
                    LoggerManager.didRecieveError(error)
                }
                LoggerManager.log("Failed to auth with Layer")
            }
        })
    }
    
    ///Layer Client
    
    
    func layerClient(_ client: LYRClient, didReceiveAuthenticationChallengeWithNonce nonce: String) {
        LoggerManager.log("Auth Challenge with Nonce")
        getToken(nonce)
    }
    
    func layerClientDidConnect(_ client: LYRClient) {
        LoggerManager.log("Did connect")
    }
    
    ///Make sure we have all changes before we pass off to campaigns manager
    func layerClient(_ client: LYRClient, objectsDidChange changes: [LYRObjectChange]) {
        synchronizationTimer?.invalidate()
        synchronizationTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(LayerManager.didFinishSync), userInfo: nil, repeats: false)
    }
    
    func layerClient(_ client: LYRClient, didFinishSynchronizationWithChanges changes: [LYRObjectChange]) {        
        synchronizationTimer?.invalidate()
        synchronizationTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(LayerManager.didFinishSync), userInfo: nil, repeats: false)
    }
    
    
    func didFinishSync() {
        do {
            try CampaignsManager.checkForCampaigns()
        }catch {
            LoggerManager.log("Failed to check for campaigns")
        }
        
    }
    
    
    func layerClient(_ client: LYRClient, didFailOperationWithError error: Error) {
        LoggerManager.log("Sync Failed: \(error.localizedDescription)")
    }

}
