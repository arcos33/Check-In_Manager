//
//  NSDate+Checkin.swift
//  check-in
//
//  Created by Joel on 8/29/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation

extension NSDate {
    class func stringFromDate(date: NSDate) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "GMT")
        return formatter.stringFromDate(date)
    }
    
    class func dateFromString(string: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "GMT")
        return formatter.dateFromString(string)!
    }
    
    class func getCurrentLocalDate()-> NSDate {
        var now = NSDate()
        let nowComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        nowComponents.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: now)
        nowComponents.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: now)
        nowComponents.day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: now)
        nowComponents.hour = NSCalendar.currentCalendar().component(NSCalendarUnit.Hour, fromDate: now)
        nowComponents.minute = NSCalendar.currentCalendar().component(NSCalendarUnit.Minute, fromDate: now)
        nowComponents.second = NSCalendar.currentCalendar().component(NSCalendarUnit.Second, fromDate: now)
        nowComponents.timeZone = NSTimeZone(abbreviation: "GMT")
        now = calendar.dateFromComponents(nowComponents)!
        return now
    }
    
    class func getTimeInHoursAndMinutes(date: NSDate) -> String {
        let df = NSDateFormatter()
        df.dateFormat = "h:mm a"
        df.timeZone = NSTimeZone(name: "GMT")
        return df.stringFromDate(date)
    }
    

}