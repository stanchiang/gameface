//
//  Auth.swift
//  Drift
//
//  Created by Eoin O'Connell on 29/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import UIKit
import ObjectMapper

struct Auth: Mappable {
    
    var accessToken: String!
    var enduser: User?
    
    init?(map: Map) {
        //These fields are required, without them we fail to init the object
        accessToken = map["accessToken"].validNotEmpty()
        
        if !map.isValidNotEmpty{
            LoggerManager.log("Auth Serialisation Failed")
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        accessToken <- map["accessToken"]
        enduser     <- map["endUser"]
    }
}
