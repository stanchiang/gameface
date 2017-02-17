//
//  CampaignOrganizer.swift
//  Drift
//
//  Created by Eoin O'Connell on 04/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


import ObjectMapper
///Data Structure for the Drift user who made the campaign
class CampaignOrganizer: Mappable, Equatable {
    
    var userId: Int?
    var name: String?
    var avatarURL: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
   
    func mapping(map: Map) {
        userId      <- map["id"]
        name        <- map["name"]
        avatarURL   <- map["avatarUrl"]
    }
}

func ==(lhs: CampaignOrganizer, rhs: CampaignOrganizer) -> Bool {
    return lhs.userId == rhs.userId
}
