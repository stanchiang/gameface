//
//  UserManager.swift
//  Drift
//
//  Created by Eoin O'Connell on 17/08/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit

class UserManager {

    static let sharedInstance: UserManager = UserManager()
    
    
    
    var completionDict: [Int: [((_ user: CampaignOrganizer?) -> ())]] = [:]
    
    var userCache: [Int: (CampaignOrganizer)] = [:]

    

    
    
    func userMetaDataForUserId(_ userId: Int, completion: @escaping (_ user: CampaignOrganizer?) -> ()) {
        
        if let user = userCache[userId] {
            completion(user)
        }else{
            
            if let completionArr = completionDict[userId] {
                completionDict[userId] = completionArr + [completion]
            }else{
                completionDict[userId] = [completion]
                APIManager.getUser(userId, orgId: DriftDataStore.sharedInstance.embed!.orgId, authToken: DriftDataStore.sharedInstance.auth!.accessToken, completion: { (result) -> () in
                  
                    switch result {
                    case .success(let users):
                        
                        for user in users {
                            self.userCache[user.userId ?? userId] = user
                            self.executeCompletions(userId, user: user)
                        }
                        
                    case .failure(_):
                        self.executeCompletions(userId, user: nil)
                    }
                })
            }
        }
    }
    
    func executeCompletions(_ userId: Int, user : CampaignOrganizer?) {
        if let completions = self.completionDict[userId] {
            for completion in completions {
                completion(user)
            }
        }
        completionDict[userId] = nil
    }
}
