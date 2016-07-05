//
//  CheckInEvent+CoreDataProperties.swift
//  check-in
//
//  Created by Joel on 6/28/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CheckInEvent {

    @NSManaged var uniqueID: NSNumber?
    @NSManaged var time: NSDate?
    @NSManaged var clientID: NSNumber?
    @NSManaged var serviceTypeID: NSNumber?
    @NSManaged var status: NSString?

}
