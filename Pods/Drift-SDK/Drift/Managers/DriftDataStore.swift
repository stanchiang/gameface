//
//  DriftDataStore.swift
//  Drift
//
//  Created by Eoin O'Connell on 28/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import ObjectMapper

///Datastore for caching Embed and Auth object between app opens
class DriftDataStore {

    static let driftAuthCacheString = "DriftSDKAuthDataJSONCache"
    static let driftEmbedCacheString = "DriftSDKEmbedJSONCache"
    
    fileprivate (set) var auth: Auth?
    fileprivate (set) var embed: Embed?
    
    static var sharedInstance: DriftDataStore = {
        let store = DriftDataStore()
        store.loadData()
        return store
    }()
    
    func setAuth(_ auth: Auth) {
        self.auth = auth
        saveData()
    }
    
    func setEmbed(_ embed: Embed) {
        self.embed = embed
        saveData()
    }

    
    func loadData(){
        
        let userDefs = UserDefaults.standard
        
        if let data = userDefs.string(forKey: DriftDataStore.driftAuthCacheString), let json = convertStringToDictionary(data) {
            let tempAuth = Auth(JSON: json)
            if let auth =  tempAuth{
                self.auth = auth
            }else{
                LoggerManager.log("Failed to load auth")
            }
        }
        
        if let data = userDefs.string(forKey: DriftDataStore.driftEmbedCacheString), let json = convertStringToDictionary(data) {
            let tempEmbed = Mapper<Embed>().map(JSON: json)
            
            if let embed = tempEmbed {
                self.embed = embed
            }else{
                LoggerManager.log("Failed to load embed")
            }
        }
    }
    
    func saveData(){
        let userDefs = UserDefaults.standard
        
        if let embed = embed, let json = convertDictionaryToString(embed.toJSON() as [String : AnyObject]) {
            userDefs.set(json, forKey: DriftDataStore.driftEmbedCacheString)
        }else{
            LoggerManager.log("Failed to save embed")
        }
        
        if let auth = auth, let json = convertDictionaryToString( auth.toJSON() as [String : AnyObject]) {
            userDefs.set(json, forKey: DriftDataStore.driftAuthCacheString)
        }
        
        userDefs.synchronize()
        
        DriftDataStore.sharedInstance = self
    }
    
    func removeData(){
        let userDefs = UserDefaults.standard
        userDefs.removeObject(forKey: DriftDataStore.driftAuthCacheString)
        userDefs.removeObject(forKey: DriftDataStore.driftEmbedCacheString)
        userDefs.synchronize()
        auth = nil
        embed = nil
    }
    
    
    ///Converts string to JSON - Used in loading from cache
    fileprivate func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                LoggerManager.didRecieveError(error)
            }
        }
        return nil
    }
    
    ///Converst JSON to string for caching in NSUserDefaults
    fileprivate func convertDictionaryToString(_ json: [String: AnyObject]) -> String? {
        
        if JSONSerialization.isValidJSONObject(json) {
        
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                return String(data: jsonData, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                LoggerManager.didRecieveError(error)
            }
        }
        return nil
    }
}

extension DriftDataStore{
    
    func generateBackgroundColor() -> UIColor {
        if let backgroundColor = embed?.backgroundColor {
            return UIColor(hexString: backgroundColor)
        }
        return UIColor(red:0.54, green:0.4, blue:1, alpha:1)
    }
    
    func generateForegroundColor() -> UIColor {
        if let foregroundColor = embed?.foregroundColor {
            return UIColor(hexString: foregroundColor)
        }
        return UIColor(red:0.54, green:0.4, blue:1, alpha:1)
    }
    
    static let primaryFontColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
    static let secondaryFontColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
    
}
