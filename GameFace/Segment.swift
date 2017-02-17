//
//  Segment.swift
//  GameFace
//
//  Created by Stanley Chiang on 2/16/17.
//  Copyright © 2017 Stanley Chiang. All rights reserved.
//

import Foundation
import Analytics

class Segment {
    static let sharedInstance = Segment()
    fileprivate init() {}
    
    func userSetup() {
        SEGAnalytics.shared().alias(UIDevice.current.identifierForVendor!.uuidString)
        SEGAnalytics.shared().identify(UIDevice.current.identifierForVendor!.uuidString)
    }
    
    func configuration() {
        let configuration: SEGAnalyticsConfiguration = SEGAnalyticsConfiguration(writeKey: Constants.segmentWriteKey)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        SEGAnalytics.setup(with: configuration)
        SEGAnalytics.shared().identify(UIDevice.current.identifierForVendor!.uuidString)
    }
    
    func recordEvent(event:Event) {
        SEGAnalytics.shared().track(event.rawValue)
    }

}
