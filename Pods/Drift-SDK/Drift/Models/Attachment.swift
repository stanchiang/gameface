//
//  Attachment.swift
//  Drift
//
//  Created by Brian McDonald on 29/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper

open class Attachment: Mappable, Hashable{
    var id = 0
    var fileName = ""
    var size = 0
    var data = Data()
    var mimeType = ""
    var conversationId = 0
    var publicPreviewURL: String?
    
    open func mapping(map: Map) {
        id          <- map["id"]
        fileName    <- map["fileName"]
        size        <- map["size"]
        data        <- map["data"]
        mimeType    <- map["mimeType"]
        conversationId <- map["conversationId"]
        publicPreviewURL <- map["publicPreviewUrl"]
    }
    
    open var hashValue: Int {
        return id
    }
    
    required convenience public init?(map: Map) {
        self.init()
    }
}

public func ==(lhs: Attachment, rhs: Attachment) -> Bool {
    return lhs.id == rhs.id
}
