//
//  NPSAttributes.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper
///Attributes used for NPS
class NPSAttributes: Mappable {
    
    var cta: CTA?
    var followUpQuestion: String?
    var campaignId: Int?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        cta                 <- map["cta"]
        followUpQuestion    <- map["followUpMessage"]
        campaignId          <- map["campaignId"]
    }
}
