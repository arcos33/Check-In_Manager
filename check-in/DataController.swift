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
    
    func dataRequest()
    {
        // Get all checkinEvents for today from DB server.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/glamour/mobile_api/get_checkinEvents.php")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error = \(error)")
                return
            }
            let responseBody = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if responseBody == "null" {
                return
            }
            
            do {
                // Do a fetch request to get all checkinEvent records
                let fetch = NSFetchRequest(entityName: "CheckInEvent")
                var checkinEvents:[CheckInEvent]?
                do {
                    checkinEvents = try appDelegate.managedObjectContext.executeFetchRequest(fetch) as? [CheckInEvent]
                }
                catch {
                    print("error = \(error)")
                }
                
                if checkinEvents?.count == 0 {
                    // If the response body is valid JSON then iterate through all dictionaries and save checkinEvents to coredata.
                    let jsonString: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                    for object in jsonString as! [Dictionary<String,AnyObject>] {
                        let tempId = object["id"]!
                        let checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: appDelegate.managedObjectContext) as! CheckInEvent
                        let df = NSDateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        checkinEvent.checkinTimestamp = df.dateFromString(object["checkinTimestamp"]! as! String)
                        checkinEvent.completedTimestamp = df.dateFromString(object["completedTimestamp"]! as! String)
                        checkinEvent.uniqueID = NSNumber(int: tempId.intValue)
                        checkinEvent.name = object["name"] as? String
                        checkinEvent.phone = object["phone"] as? String
                        checkinEvent.status = object["status"] as? String
                        do {
                            try appDelegate.managedObjectContext.save()
                        }
                        catch {
                            print("error: \(error)")
                        }
                    }
                }
                else {
                    var existingCheckinEventIDS = Array<Int>()
                    for existingCheckinEvent in checkinEvents! {
                        existingCheckinEventIDS.append((existingCheckinEvent.uniqueID?.integerValue)!)
                    }
                    let jsonString: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                    for object in jsonString as! [Dictionary<String,AnyObject>] {
                        let tempID = object["id"]!
                        //print(tempID.integerValue)
                        if !existingCheckinEventIDS.contains((tempID.integerValue)!) {
                            
                            let checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: appDelegate.managedObjectContext) as! CheckInEvent
                            let df = NSDateFormatter()
                            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            checkinEvent.checkinTimestamp = df.dateFromString(object["checkinTimestamp"]! as! String)
                            checkinEvent.completedTimestamp = df.dateFromString(object["completedTimestamp"]! as! String)
                            checkinEvent.uniqueID = NSNumber(int: tempID.intValue)
                            checkinEvent.name = object["name"] as? String
                            checkinEvent.phone = object["phone"] as? String
                            checkinEvent.status = object["status"] as? String
                            do {
                                try appDelegate.managedObjectContext.save()
                            }
                            catch {
                                print("error: \(error)")
                            }
                        }
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}