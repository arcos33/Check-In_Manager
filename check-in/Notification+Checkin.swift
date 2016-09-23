//
//  Notification+Checkin.swift
//  check-in
//
//  Created by Joel on 9/22/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation

extension Notification {
    // Localization Notifications
    static let languageChangeNotification = Notification.Name("LCLLanguageChangeNotification")
    
    // DataController Notifications
    static let didReceiveCompanyIDNotification = Notification.Name("DataControllerDidReceiveCompanyIDNotification")
    static let didReceiveAuthenticationNotification = Notification.Name("DataControllerDidReceiveAuthenticationNotification")
    static let didReceiveCheckinRecordsNotification = Notification.Name("DataControllerDidReceiveCheckinRecordsNotification")
    static let stylistRecordsChangedNotification = Notification.Name("DataControllerStylistRecordsChangedNotification")
    static let serviceRecordsChangedNotification = Notification.Name("DataControllerServiceRecordsChangedNotification")
}
