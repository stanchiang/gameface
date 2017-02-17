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
    
    func configuration() {
        let configuration: SEGAnalyticsConfiguration = SEGAnalyticsConfiguration(writeKey: Constants.segmentWriteKey)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        SEGAnalytics.setup(with: configuration)
    }
}
