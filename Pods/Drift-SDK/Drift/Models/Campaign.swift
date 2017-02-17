//
//  MessagePartData.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper
class Campaign: Mappable {
    
    /**
        The type of message that the SDK can parse
        - Announcement: Announcement Campaign
        - NPS: NPS Campaign
        - NPS Response: Response to an NPS Campaign - Don't show NPS is conversation contains NPS Response
     */
    enum MessageType: String {
        case Announcement = "ANNOUNCEMENT"
        case NPS = "NPS"
        case NPSResponse = "NPS_RESPONSE"
    }
    
    var orgId: Int?
    var id: Int?
    var uuid: String?
    var messageType: MessageType!
    var createdAt: Date?
    var bodyText: String?
    var authorId: Int?
    var conversationId: Int?
    
    var npsAttributes: NPSAttributes?
    var announcementAttributes: AnnouncementAttributes?
    var npsResponseAttributes: NPSResponseAttributes? 
    
    required convenience init?(map: Map) {
        
        if map.JSON["type"] as? String == nil || MessageType(rawValue: map.JSON["type"] as! String) == nil{
            LoggerManager.log(map.JSON["type"] as? String ?? "")
            return nil
        }
        
        self.init()
    }
    
    func mapping(map: Map) {
        orgId           <- map["orgId"]
        id              <- map["id"]
        uuid            <- map["uuid"]
        messageType     <- map["type"]
        createdAt       <- (map["createdAt"], DateTransform())
        bodyText        <- map["body"]
        authorId        <- map["authorId"]
        conversationId  <- map["conversationId"]
        
        if let messageType = messageType {
            switch messageType {
            case .Announcement:
                announcementAttributes <- map["attributes"]
            case .NPS:
                npsAttributes         <- map["attributes"]
            case .NPSResponse:
                npsResponseAttributes <- map["attributes"]
            }
        }
    }
}
