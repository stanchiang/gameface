//
//  CTA.swift
//  Driftt
//
//  Created by Eoin O'Connell on 22/01/2016.
//  Copyright © 2016 Drift. All rights reserved.
//

import ObjectMapper
class CTA: Mappable {
    
    /**
      Types of CTA the SDK can Parse
        - ChatResponse: Opens a MailCompose window when tapped
        - LinkToURL: Opens URL when tapped
     */
    enum CTAType: String {
        case ChatResponse = "CHAT_RESPONSE"
        case LinkToURL = "LINK_TO_URL"
    }
    
    var copy: String?
    var ctaType: CTAType?
    var urlLink: URL?

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        copy        <- map["copy"]
        ctaType     <- map["CtaType"]
        urlLink     <- map["UrlLink"]
    }
}
