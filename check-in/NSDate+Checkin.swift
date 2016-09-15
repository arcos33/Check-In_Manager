//
//  NSDate+Checkin.swift
//  check-in
//
//  Created by Joel on 8/29/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation

extension Date {
    static func stringFromDate(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter.string(from: date)
    }
    
    static func dateFromString(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter.date(from: string)!
    }
    
    static func getCurrentLocalDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = (Calendar.current as NSCalendar).component(NSCalendar.Unit.year, from: now)
        nowComponents.month = (Calendar.current as NSCalendar).component(NSCalendar.Unit.month, from: now)
        nowComponents.day = (Calendar.current as NSCalendar).component(NSCalendar.Unit.day, from: now)
        nowComponents.hour = (Calendar.current as NSCalendar).component(NSCalendar.Unit.hour, from: now)
        nowComponents.minute = (Calendar.current as NSCalendar).component(NSCalendar.Unit.minute, from: now)
        nowComponents.second = (Calendar.current as NSCalendar).component(NSCalendar.Unit.second, from: now)
        (nowComponents as NSDateComponents).timeZone = TimeZone(abbreviation: "GMT")
        now = calendar.date(from: nowComponents)!
        return now
    }
    
    static func getTimeInHoursAndMinutes(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        df.timeZone = TimeZone(identifier: "GMT")
        return df.string(from: date)
    }
    

}
