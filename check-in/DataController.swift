//
//  DataController.swift
//  check-in
//
//  Created by Joel on 6/28/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataController: NSObject {
    static let sharedInstance = DataController()
    
    //var managedObjectContext: NSManagedObjectContext
    
    override private init() {} // This prevents others from using the default '()' initializer for this class.
    /*
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("ClientOrganizerDataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.URLByAppendingPathComponent("ClientOrganizerDataModel.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
 */
    
    func createTestData() {
        // if app has already loaded once then don't add anythingn to core data.
        if ((NSUserDefaults.standardUserDefaults().valueForKey("loggedIn")) != nil) {
            return
        }
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "loggedIn")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let serviceType = NSEntityDescription.insertNewObjectForEntityForName("ServiceType", inManagedObjectContext: appDelegate.managedObjectContext) as! ServiceType
        serviceType.uniqueID = NSNumber(int: 1)
        serviceType.name = "follow-up"
        
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(error)")
        }
        
        serviceType.uniqueID = NSNumber(int: 1)
        serviceType.name = "appointment"
        
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(error)")
        }
        
        let client = NSEntityDescription.insertNewObjectForEntityForName("Client", inManagedObjectContext: appDelegate.managedObjectContext) as! Client
        client.fName = "Mike"
        client.lName = "Tyson"
        client.phoneNumber = "801-232-2333"
        client.uniqueID = NSNumber(int: 1)
        
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(error)")
        }
        
        client.fName = "Manny"
        client.lName = "Pacquiao"
        client.phoneNumber = "801-471-9087"
        client.uniqueID = NSNumber(int: 2)
        
        
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(error)")
        }
        
        var checkInEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: appDelegate.managedObjectContext) as! CheckInEvent
        
        checkInEvent.uniqueID = NSNumber(int: 1)
        checkInEvent.time = NSDate()
        checkInEvent.clientID = client.uniqueID
        checkInEvent.serviceTypeID = serviceType.uniqueID
        checkInEvent.status = "active"
        
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(error)")
        }
        
        checkInEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: appDelegate.managedObjectContext) as! CheckInEvent
        checkInEvent.uniqueID = NSNumber(int: 2)
        checkInEvent.time = NSDate()
        checkInEvent.clientID = client.uniqueID
        checkInEvent.serviceTypeID = serviceType.uniqueID
        checkInEvent.status = "inactive"
        
        do {
            try appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(error)")
        }
        
    }
    
    
}