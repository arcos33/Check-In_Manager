//
//  Client+CoreDataProperties.swift
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

extension Client {

    @NSManaged var fName: String?
    @NSManaged var lName: String?
    @NSManaged var phoneNumber: NSNumber?
    @NSManaged var uniqueID: NSNumber?

}
