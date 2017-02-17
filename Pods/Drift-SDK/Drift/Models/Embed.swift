//
//  Embed.swift
//  Drift
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper
///Embed - The organisation specific data used to customise the SDK for each organization
struct Embed: Mappable {
    
    var orgId: Int!
    var embedId: String!
    var inboxId: Int!
    
    var layerAppId: String!
    var clientId: String!
    var redirectUri: String!
    
    var backgroundColor: String?
    var foregroundColor: String?
    var welcomeMessage: String?
    
    var organizationName: String?
    
    var inboxEmailAddress: String?
    var refreshRate: Int?
    
    init?(map: Map) {
        //These fields are required, without them we fail to init the object
        orgId       = map["orgId"].validNotEmpty()
        embedId     = map["id"].validNotEmpty()
        inboxId     = map["configuration.inboxId"].validNotEmpty()
        layerAppId  = map["configuration.layerAppId"].validNotEmpty()
        clientId    = map["configuration.authClientId"].validNotEmpty()
        redirectUri = map["configuration.redirectUri"].validNotEmpty()
        
        if !map.isValidNotEmpty{
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        orgId               <- map["orgId"]
        embedId             <- map["id"]
        inboxId             <- map["configuration.inboxId"]
        layerAppId          <- map["configuration.layerAppId"]
        clientId            <- map["configuration.authClientId"]
        redirectUri         <- map["configuration.redirectUri"]
        backgroundColor     <- map["configuration.theme.backgroundColor"]
        foregroundColor     <- map["configuration.theme.foregroundColor"]
        welcomeMessage      <- map["configuration.theme.welcomeMessage"]
        organizationName    <- map["configuration.organizationName"]
        inboxEmailAddress   <- map["configuration.inboxEmailAddress"]
        refreshRate         <- map["configuration.refreshRate"]
    }
}
