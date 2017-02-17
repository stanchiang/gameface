//
//  NPSResponseAttributes.swift
//  Drift
//
//  Created by Eoin O'Connell on 01/02/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper
///NPS Response
class NPSResponseAttributes: Mappable {
    
    var campaignId: Int?
    var dismissed: Bool?
    var numericResponse: Int?
    var textResponse:String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        campaignId      <- map["campaignId"]
        dismissed       <- map["dismissed"]
        textResponse    <- map["textResponse"]
        numericResponse <- map["numericResponse"]
    }
}
