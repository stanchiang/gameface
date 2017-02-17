//
//  DriftDateFormatter.swift
//  Conversations
//
//  Created by Brian McDonald on 16/05/2016.
//  Copyright © 2016 Drift. All rights reserved.
//


open class DriftDateFormatter: DateFormatter {
    
    open func createdAtStringFromDate(_ date: Date) -> String{
        dateFormat = "HH:mm"
        timeStyle = .short
        return string(from: date)
    }
    
    open func updatedAtStringFromDate(_ date: Date) -> String{
        let now = Date()
        if (Calendar.current as NSCalendar).component(.day, from: date) != (Calendar.current as NSCalendar).component(.day, from: now){
            dateStyle = .short
        }else{
            dateFormat = "H:mm a"
        }
        return string(from: date)
    }
    
    open func headerStringFromDate(_ date: Date) -> String{
        let now = Date()
        if (Calendar.current as NSCalendar).component(.day, from: date) != (Calendar.current as NSCalendar).component(.day, from: now){
            dateFormat = "MMMM d"
        }else{
            return "Today"
        }
        return string(from: date)
    }
    
}
