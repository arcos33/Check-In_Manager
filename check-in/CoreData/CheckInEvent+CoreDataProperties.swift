//
//  CheckInEvent+CoreDataProperties.swift
//  check-in
//
//  Created by Joel on 7/8/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CheckInEvent {

    @NSManaged var clientID: NSNumber?
    @NSManaged var serviceTypeID: NSNumber?
    @NSManaged var status: String?
    @NSManaged var uniqueID: NSNumber?
    @NSManaged var client: Client?
    @NSManaged var name: String?
    @NSManaged var checkinTimestamp: NSDate?
    @NSManaged var completedTimestamp: NSDate?
    @NSManaged var phone: String?
    @NSManaged var stylist: String?
    @NSManaged var service: String?
    @NSManaged var paymentType: String?
    @NSManaged var ticketNumber: String?
    @NSManaged var updateDate: NSDate?
    @NSManaged var amountCharged: String?
}
