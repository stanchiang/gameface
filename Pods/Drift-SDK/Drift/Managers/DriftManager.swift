//
//  DriftManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import Foundation
import MessageUI

class DriftManager: NSObject {
    
    static var sharedInstance: DriftManager = DriftManager()
    var debug: Bool = false
    var directoryURL: URL?
    ///Used to store register data while we wait for embed to finish in case where register and embed is called together
    var registerInfo: (userId: String, email: String, attrs: [String: AnyObject]?)?

    
    fileprivate override init(){
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(DriftManager.didEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    class func createTemporaryDirectory(){
        sharedInstance.directoryURL =  URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
        do {
            if let directoryURL = sharedInstance.directoryURL{
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            sharedInstance.directoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
    
    ///Call Embeds API if needed
    class func retrieveDataFromEmbeds(_ embedId: String) {
        
        if let pastEmbedId = DriftDataStore.sharedInstance.embed?.embedId {
            //New Embed Account - Logout and continue to get new
            if pastEmbedId != embedId {
                Drift.logout()
            }
        }
        
        //New User - First Time Launch
        getEmbedData(embedId) { (success) in
            if let registerInfo = DriftManager.sharedInstance.registerInfo , success {
                DriftManager.registerUser(registerInfo.userId, email: registerInfo.email, attrs: registerInfo.attrs)
                DriftManager.sharedInstance.registerInfo = nil
            }
        }
    }
    
    class func debugMode(_ debug:Bool){
        sharedInstance.debug = debug
    }
    
    class func showConversations(){
        if (DriftDataStore.sharedInstance.auth != nil){
            PresentationManager.sharedInstance.showConversationList()
        }else{
            LoggerManager.log("No Auth, unable to show conversations for user")
        }
    }
    
    /**
     Gets Auth for user - Calls Identify if new user
    */
    class func registerUser(_ userId: String, email: String, attrs: [String: AnyObject]? = nil){
        
        guard let orgId = DriftDataStore.sharedInstance.embed?.orgId else {
            LoggerManager.log("No Embed, not registering user - Waiting for Embeds to complete")
            DriftManager.sharedInstance.registerInfo = (userId, email, attrs)
            return
        }
        
        if let auth = DriftDataStore.sharedInstance.auth {
            
            if let _ = auth.enduser {
                
                getAuth(email, userId: userId) { (success) in
                    if success {
                        self.initializeLayer(userId)
                    }
                }
            }else{
                ///No Users. lets Auth
                getAuth(email, userId: userId) { (success) in
                    if success {
                        self.initializeLayer(userId)
                    }
                }
            }
            
        }else{
            ///New User
            //Call Identify
            //Call Auth
            
            APIManager.postIdentify(orgId, userId: userId, email: email, attributes: nil) { (result) -> () in }
            getAuth(email, userId: userId) { (success) in
                if success {
                    self.initializeLayer(userId)
                }
            }
        }
    }
    
    /**
     Delete Data Store
     */
    class func logout(){
        DriftDataStore.sharedInstance.removeData()
    }
    
    /**
     Calls Auth and caches
     - parameter email: Users email
     - parameter userId: User Id from app data base
     - returns: completion with success bool
    */
    class func getAuth(_ email: String, userId: String, completion: @escaping (_ success: Bool) -> ()) {
        
        if let orgId = DriftDataStore.sharedInstance.embed?.orgId, let clientId = DriftDataStore.sharedInstance.embed?.clientId, let redirURI = DriftDataStore.sharedInstance.embed?.redirectUri {
            APIManager.getAuth(email, userId: userId, redirectURL: redirURI, orgId: orgId, clientId: clientId, completion: { (result) -> () in
                switch result {
                case .success(let auth):
                    DriftDataStore.sharedInstance.setAuth(auth)
                    completion(true)
                case .failure(let error):
                    LoggerManager.log("Failed to get Auth: \(error)")
                    completion(false)
                }
            })
        }else{
            LoggerManager.log("Not enough data to get Auth")
        }
    }
    
    /**
        Called when app is opened from background - Refresh Identify if logged in
    */
    func didEnterForeground(){
        if let user = DriftDataStore.sharedInstance.auth?.enduser, let orgId = user.orgId, let userId = user.externalId, let email = user.email {
            APIManager.postIdentify(orgId, userId: userId, email: email, attributes: nil) { (result) -> () in }

        }else{
            LoggerManager.log("No End user to post identify for")
        }
    }
    
    /**
     Once we have a userId from Auth - Start Layer Auth Handoff to Layer Manager
    */
    fileprivate class func initializeLayer(_ userId: String) {

        if let appId = DriftDataStore.sharedInstance.embed?.layerAppId, let userId = DriftDataStore.sharedInstance.auth?.enduser?.userId {
            LayerManager.initialize(appId, userId: userId) { (success) in
                if success {
                    do {
                        try CampaignsManager.checkForCampaigns()
                    } catch {
                        LoggerManager.log("Announcements Error")
                    }
                }
            }
        }
    }
    
    class func getEmbedData(_ embedId: String, completion: @escaping (_ success: Bool) -> ()){
        let refresh = DriftDataStore.sharedInstance.embed?.refreshRate
        APIManager.getEmbeds(embedId, refreshRate: refresh) { (result) -> () in
            
            switch result {
            case .success(let embed):
                LoggerManager.log("Updated Embed Id")
                DriftDataStore.sharedInstance.setEmbed(embed)
                completion(true)
            case .failure(let error):
                LoggerManager.log(error.localizedDescription)
                completion(false)
            }
        }
    }
}

///Convenience Extension to dismiss a MFMailComposeViewController - Used as views will not stay in window and delegate would become nil
extension DriftManager: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
