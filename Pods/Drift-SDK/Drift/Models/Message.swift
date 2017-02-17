//
//  Message.swift
//  Drift
//
//  Created by Brian McDonald on 25/07/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


import ObjectMapper

public enum ContentType: String{
    case Chat = "CHAT"
}

public enum Type: String{
    case Chat = "CHAT"
}

public enum AuthorType: String{
    case User = "USER"
    case EndUser = "END_USER"
}

public enum SendStatus: String{
    case Sent = "SENT"
    case Pending = "PENDING"
    case Failed = "FAILED"
}

open class Message: Mappable, Equatable, Hashable{
    var id: Int!
    var uuid: String?
    var inboxId: Int!
    var body: String?
    var attachments: [Int] = []
    var contentType = ContentType.Chat.rawValue
    var createdAt = Date()
    var authorId: Int!
    var authorType: AuthorType!
    var type: Type!
    var context: Context?
    
    var conversationId: Int!
    var requestId: Double = 0
    var sendStatus: SendStatus = SendStatus.Sent
    var formattedBody: NSAttributedString?

    open var hashValue: Int {
        return id
    }
    
    required convenience public init?(map: Map) {
        if map.JSON["contentType"] as? String == nil || ContentType(rawValue: map.JSON["contentType"] as! String) == nil{
            return nil
        }
        
        if let body = map.JSON["body"] as? String, let attachments = map.JSON["attachments"] as? [Int]{
            if body == "" && attachments.count == 0{
                return nil
            }
        }
        self.init()
    }
    
    open func mapping(map: Map) {
        id                      <- map["id"]
        uuid                    <- map["uuid"]
        inboxId                 <- map["inboxId"]
        body                    <- map["body"]
        attachments             <- map["attachments"]
        contentType             <- map["contentType"]
        createdAt               <- (map["createdAt"], DriftDateTransformer())
        authorId                <- map["authorId"]
        authorType              <- map["authorType"]
        type                    <- map["type"]
        conversationId          <- map["conversationId"]
        context                 <- map["context"]

        do {
            let htmlStringData = (body ?? "").data(using: String.Encoding.utf8)!
            let attributedHTMLString = try NSMutableAttributedString(data: htmlStringData, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue, ], documentAttributes: nil)
            
            if let font = UIFont(name: "AvenirNext-Regular", size: 16){
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.paragraphSpacing = 0.0
                attributedHTMLString.addAttributes([NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle], range: NSRange(location: 0, length: attributedHTMLString.length))
                formattedBody = attributedHTMLString
            }
        }catch{
            //Unable to format HTML body, in this scenario the raw html will be shown in the message cell
        }
    }

}

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.uuid == rhs.uuid
}

