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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    lazy var configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.configuration)
    
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
    
    func getCheckinRecords()
    {
        // Get all checkinEvents for today from DB server.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(appDelegate.companyPath)/mobile_api/get/get_checkinEvents.php")!
        
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
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
                    print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                }
                
                if checkinEvents?.count == 0 {
                    // If the response body is valid JSON then iterate through all dictionaries and save checkinEvents to coredata.
//                    let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
//                    print("responseBody: \(responseBody)")
                    print()
                    let jsonResponseString: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [Dictionary<String, AnyObject>]
                    for object in jsonResponseString as! [Dictionary<String,AnyObject>] {
                        let tempId = object["id"]!
                        let checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: appDelegate.managedObjectContext) as! CheckInEvent
                        
                        checkinEvent.checkinTimestamp = NSDate.dateFromString(object["checkinTimestamp"]! as! String)
                        checkinEvent.uniqueID = NSNumber(int: tempId.intValue)
                        checkinEvent.name = object["name"] as? String
                        checkinEvent.phone = object["phone"] as? String
                        checkinEvent.status = object["status"] as? String
                        
                        if let completedTimeStampString = object["completedTimestamp"]! as? String {
                            checkinEvent.completedTimestamp = NSDate.dateFromString(completedTimeStampString)
                        }
                        
                        if let serviceString = object["service"] as? String {
                            checkinEvent.service = serviceString
                        }
                        
                        if let stylistString = object["stylist"] as? String {
                            checkinEvent.stylist = stylistString
                        }
                        
                        if let ticketNumberString = object["ticketNumber"] as? String {
                            checkinEvent.ticketNumber = ticketNumberString
                        }
                        
                        if let paymentTypeString = object["paymentType"] as? String {
                            checkinEvent.paymentType = paymentTypeString
                        }
                        
                        if let amountChargedString = object["amountCharged"] as? String {
                            checkinEvent.amountCharged = amountChargedString
                        }
                        
                        if let updateDateString = object["updateDate"]! as? String {
                            checkinEvent.updateDate = NSDate.dateFromString(updateDateString)
                        }
                        
                        do {
                            try appDelegate.managedObjectContext.save()
                        }
                        catch {
                            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveCheckinRecordsNotification", object: nil)
                }
                else {
                    var existingCheckinEventIDS = Array<Int>()
                    var existingCheckinEventMap = Dictionary<Int, CheckInEvent>()
                    
                    for existingCheckinEvent in checkinEvents! {
                        existingCheckinEventIDS.append((existingCheckinEvent.uniqueID?.integerValue)!)
                        existingCheckinEventMap[(existingCheckinEvent.uniqueID?.integerValue)!] = existingCheckinEvent
                    }
                    let jsonString: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSArray
                    for checkinEventDB in jsonString as! [Dictionary<String,AnyObject>] {
                        let tempID = checkinEventDB["id"]!
                        
                        
                        if !existingCheckinEventIDS.contains((tempID.integerValue)!) {
                            
                            let checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: appDelegate.managedObjectContext) as! CheckInEvent
                            checkinEvent.checkinTimestamp = NSDate.dateFromString(checkinEventDB["checkinTimestamp"]! as! String)
                            checkinEvent.uniqueID = NSNumber(int : tempID.intValue)
                            checkinEvent.name = checkinEventDB["name"] as? String
                            checkinEvent.phone = checkinEventDB["phone"] as? String
                            checkinEvent.status = checkinEventDB["status"] as? String
                            
                            if let completedTimeStampString = checkinEventDB["completedTimestamp"]! as? String {
                                checkinEvent.completedTimestamp = NSDate.dateFromString(completedTimeStampString)
                            }
                            
                            if let stylistString = checkinEventDB["stylist"] as? String {
                                checkinEvent.stylist = stylistString
                            }
                            
                            if let serviceString = checkinEventDB["service"] as? String {
                                checkinEvent.service = serviceString
                            }
                            
                            if let ticketNumberString = checkinEventDB["ticketNumber"] as? String {
                                checkinEvent.ticketNumber = ticketNumberString
                            }
                            
                            if let paymentTypeString = checkinEventDB["paymentType"] as? String {
                                checkinEvent.paymentType = paymentTypeString
                            }
                            
                            if let amountChargedString = checkinEventDB["amountCharged"] as? String {
                                checkinEvent.amountCharged = amountChargedString
                            }
                            if let updateDateString = checkinEventDB["updateDate"]! as? String {
                                checkinEvent.updateDate = NSDate.dateFromString(updateDateString)
                            }
                            
                            do {
                                try appDelegate.managedObjectContext.save()
                            }
                            catch {
                                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                            }
                        }
                        //                        else {
                        //                            for existingCheckinEventID in existingCheckinEventIDS {
                        //                                // Find the matching checkinEvent and determine which record has the newest info.
                        //                                if existingCheckinEventID == Int(checkinEventDB["id"] as! String) {
                        //                                    let existingCheckinEvent = existingCheckinEventMap[existingCheckinEventID]
                        //
                        //                                    if let updateDateString = checkinEventDB["updateDate"]! as? String {
                        //                                        let updateDate = NSDate.dateFromString(updateDateString)
                        //
                        //                                        if existingCheckinEvent?.updateDate == nil {
                        //                                            existingCheckinEvent?.updateDate = updateDate
                        //                                        }
                        //                                        else {
                        //                                            if updateDate.compare((existingCheckinEvent?.updateDate)!) == .OrderedDescending {
                        //                                                print("date1 is later than date 2")
                        //                                            }
                        //                                            else if (updateDate.compare((existingCheckinEvent?.updateDate)!) == .OrderedAscending) {
                        //                                                print("date1 is earlier than date 2")
                        //                                            }
                        //                                            else{
                        //                                                print("dates are the same")
                        //                                                print()
                        //                                            }
                        //                                        }
                        //                                        do {
                        //                                            try appDelegate.managedObjectContext.save()
                        //                                        }
                        //                                        catch {
                        //                                            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                        //                                        }
                        //                                    }
                        //
                        //                                }
                        //                            }
                        //                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveCheckinRecordsNotification", object: nil)
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        task.resume()
    }
    
    func setURLIdentifierForCompany(companyID: String) {
        let url: NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/company_mapping.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequest = "company_id=\(companyID)".dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequest) { (data, response, error) in
            guard let data: NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            do {
                let responseBody = String(data: data, encoding: NSUTF8StringEncoding)
                if responseBody == "null" {
                    NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveCompanyIDNotification", object: false)
                    return
                }
                
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [Dictionary<String, String>]
                for dict in jsonResponse {
                    if (NSUserDefaults.standardUserDefaults().valueForKey("companyPath") as? String) == nil {
                        NSUserDefaults.standardUserDefaults().setObject(dict["baseURL"], forKey: "companyPath")
                    }
                    self.appDelegate.companyPath = dict["baseURL"]!
                    
                    if (NSUserDefaults.standardUserDefaults().valueForKey("companyName") as? String) == nil {
                        NSUserDefaults.standardUserDefaults().setObject(dict["company_name"], forKey: "companyName")
                    }
                    self.appDelegate.companyName = dict["company_name"]!
                    NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveCompanyIDNotification", object: true);
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
            //            let responseBody = String(data: data, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
        }
        task.resume()
    }
    
    func checkCredentials(username: String, password: String) {
        let url = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_users.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequest = "username=\(username)&password=\(password)" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequest) { (data, response, error) in
            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            if responseBody == "correct" {
                NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveAuthenticationNotification", object: true)
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveAuthenticationNotification", object: false)
            }
            //            print("response = \(responseBody)")
            //            print()
        }
        task.resume()
    }
    
    func downloadImage(completion: (NSData -> Void)) {
        let urlString = "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/check-in_image.png"
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let dataTask = self.session.dataTaskWithRequest(request) { (data, response, error) in
            if (error == nil) {
                if let httpResponse = response as? NSHTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        if let data = data {
                            completion(data)
                        }
                    default:
                        print("HTTP Response Code: \(httpResponse.statusCode)")
                    }
                }
            }
            else {
                print("Error Downloading File Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        dataTask.resume()
    }
    
    func updateCheckInEventAtCellIndex(checkinEvent: CheckInEvent!, index: NSInteger?) {
    NSNotificationCenter.defaultCenter().postNotificationName("DataControllerDidReceiveCheckinRecordsNotification", object: index)
        
        let url:NSURL = NSURL(string: "http://www.whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/update/update_checkinEvent.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        var requestString = String("id=\(checkinEvent.uniqueID!)")
        let date = NSDate.stringFromDate(NSDate.getCurrentLocalDate())
        requestString = requestString.stringByAppendingString("&updateDate=\(date)")
        
        if (checkinEvent.completedTimestamp != nil) {
            requestString = requestString.stringByAppendingString(String("&completedTimestamp=\(checkinEvent.completedTimestamp!)"))
        }
        if (checkinEvent.status != nil) {
            requestString = requestString.stringByAppendingString(String("&status=\(checkinEvent.status!)"))
        }
        if (checkinEvent.stylist != nil) {
            requestString = requestString.stringByAppendingString(String("&stylist=\(checkinEvent.stylist!)"))
        }
        if (checkinEvent.service != nil) {
            requestString = requestString.stringByAppendingString(String("&service=\(checkinEvent.service!)"))
        }
        if (checkinEvent.paymentType != nil) {
            requestString = requestString.stringByAppendingString(String("&paymentType=\(checkinEvent.paymentType!)"))
        }
        if (checkinEvent.ticketNumber != nil || checkinEvent.ticketNumber?.characters.count > 0) {
            requestString = requestString.stringByAppendingString(String("&ticketNumber=\(checkinEvent.ticketNumber!)"))
        }
        
        if (checkinEvent.amountCharged != nil || checkinEvent.amountCharged?.characters.count > 0) {
            requestString = requestString.stringByAppendingString(String("&amountCharged=\(checkinEvent.amountCharged!)"))
        }
        
        
        let jsonRequestString = requestString .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if responseString == "Successfully updated CheckinEvent record" {
                
            }
        })
        task.resume()
    }
    
    func getStylists(completion: (([Stylist]) -> Void)) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_stylists.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                if responseBody != "null" {
                    var stylists = [Stylist]()
                    var stylistMapping = Dictionary<String, AnyObject>()
                    
                    for object in jsonResponse as! [Dictionary<String, String>] {
                        
                        let stylist = Stylist(status: object["status"]!, id: object["id"]!, name: object["name"]!)
                        if (stylistMapping[object["id"]!] == nil) {
                            let objectID = object["id"]!
                            stylistMapping[objectID] = stylist
                        }
                        else { // update it
                            stylist.status = object["status"]
                            stylistMapping[object["id"]!] = stylist
                        }
                    }
                    var origIdArray = Array<String>()
                    for stylist in stylists {
                        origIdArray.append(stylist.id)
                    }
                    
                    stylists = []
                    for (_, value) in stylistMapping {
                        let stylist = value as! Stylist
                        stylists.append(stylist)
                    }
                    var newIdArray = Array<String>()
                    for stylist in stylists {
                        newIdArray.append(stylist.id)
                    }
                    
                    if origIdArray != newIdArray {
                        completion(stylists)
                        origIdArray = []
                        newIdArray = []
                    }
                    
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        task.resume()
    }
    
    func getServices(completion: (([Service]) -> Void)) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_services.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                var services = [Service]()
                var serviceMapping = Dictionary<String, AnyObject>()
                
                if responseBody != "null" {
                    let jsonResponseString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    for object in jsonResponseString as! [Dictionary<String, String>] {
                        let service = Service(name: object["name"]!, id: object["id"]!, status: object["status"]!)
                        if (serviceMapping[object["id"]!] == nil) {
                            serviceMapping[object["id"]!] = service
                        }
                        else { // update it
                            service.status = object["status"]
                            serviceMapping[object["id"]!] = service
                        }
                    }
                    var origIdArray = Array<String>()
                    for service in services {
                        origIdArray.append(service.id)
                    }
                    
                    services = []
                    for (_, value) in serviceMapping {
                        let service = value as! Service
                        if service.status == "available" {
                            services.append(service)
                        }
                    }
                    var newIdArray = Array<String>()
                    for service in services {
                        newIdArray.append(service.id)
                    }
                    
                    if origIdArray != newIdArray {
                        completion(services)
                        
                        origIdArray = []
                        newIdArray = []
                    }
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        task.resume()
    }
    
    func getPayments(completion: (([Payment]) -> Void)) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_payments.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                var payments = [Payment]()
                var paymentMapping = Dictionary<String, AnyObject>()
                
                if responseBody != "null" {
                    let jsonResponseString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    for object in jsonResponseString as! [Dictionary<String, String>] {
                        let payment = Payment(name: object["name"]!, id: object["id"]!, status: object["status"]!)
                        if (paymentMapping[object["id"]!] == nil) {
                            paymentMapping[object["id"]!] = payment
                        }
                        else { // update it
                            payment.status = object["status"]
                            paymentMapping[object["id"]!] = payment
                        }
                    }
                    var origIdArray = Array<String>()
                    for payment in payments {
                        origIdArray.append(payment.id)
                    }
                    
                    payments = []
                    for (_, value) in paymentMapping {
                        let payment = value as! Payment
                        if payment.status == "available" {
                            payments.append(payment)
                        }
                    }
                    var newIdArray = Array<String>()
                    for payment in payments {
                        newIdArray.append(payment.id)
                    }
                    
                    if origIdArray != newIdArray {
                        completion(payments)
                        
                        origIdArray = []
                        newIdArray = []
                    }
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        task.resume()
    }
    
    func updateStylistRecord(id: String, status: String) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/update/update_stylist.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequestString = "id=\(id)&status=\(status)" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            NSNotificationCenter.defaultCenter().postNotificationName("DataControllerStylistRecordsChangedNotification", object: nil)

            //            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
        })
        task.resume()
    }
    
    func updateServiceRecord(id: String, status: String) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/update/update_service.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequestString = "id=\(id)&status=\(status)" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("DataControllerServiceRecordsChangedNotification", object: nil)

            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            print(responseBody)
        })
        task.resume()
    }
    
    
    func postServiceRecord(name: String, completion: (([Service]) -> Void)) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/create/create_service.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequestString = "name=\(name)&status=available" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            print(responseBody)
            
            NSNotificationCenter.defaultCenter().postNotificationName("DataControllerServiceRecordsChangedNotification", object: nil)
            self.getServices({ (services) in
                completion(services)
            })
        })
        task.resume()
    }
    
    func postStylistRecord(name: String, completion: (([Stylist]) -> Void)) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/create/create_stylist.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequestString = "name=\(name)&status=available" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            //            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
            NSNotificationCenter.defaultCenter().postNotificationName("DataControllerStylistRecordsChangedNotification", object: nil)

            self.getStylists({ (stylists) in
                completion(stylists)
            })
        })
        task.resume()
    }
    
    func postCheckinEvent(phone: String, name: String, completion: () -> Void ) {
        
        let tempCleanString1 = phone.stringByReplacingOccurrencesOfString("(", withString: "")
        let tempCleanString2 = tempCleanString1.stringByReplacingOccurrencesOfString(")", withString: "")
        let tempCleanString3 = tempCleanString2.stringByReplacingOccurrencesOfString("-", withString: "")
        
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/create/create_checkinEvent.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        
        let tempCheckinTime = NSDate.stringFromDate(NSDate.getCurrentLocalDate())
        let tempCompletedTimestamp = NSDate.stringFromDate(NSDate(timeIntervalSince1970: 0))
        
        let jsonRequestString = "checkinTimestamp=\(tempCheckinTime)&completedTimestamp=\(tempCompletedTimestamp)&name=\(name)&phone=\(tempCleanString3)&status=checkedin" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            //                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //                print(responseBody)
            //                print()
            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [Dictionary<String, AnyObject>]
                for object in jsonResponse {
                    dispatch_async(dispatch_get_main_queue(), {
                        let tempId = object["id"]!
                        
                        let checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: self.appDelegate.managedObjectContext) as? CheckInEvent
                        let aDate = NSDate.dateFromString(object["checkinTimestamp"]! as! String)
                        checkinEvent!.checkinTimestamp = aDate
                        checkinEvent!.uniqueID = NSNumber(int: tempId.intValue)
                        checkinEvent!.name = object["name"] as? String
                        checkinEvent!.phone = object["phone"] as? String
                        checkinEvent!.status = object["status"] as? String
                        do {
                            try self.appDelegate.managedObjectContext.save()
                        }
                        catch {
                            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                        }
                    })
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
            completion()
            
        })
        task.resume()
    }
    
    func updatePromotionMessage(let promotionMessageTuple: (message: String?, status: String?)) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/update/update_promotional_message.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        var requestString = String()
        
        if let messageString = promotionMessageTuple.message {
            requestString = requestString.stringByAppendingString("content=\(messageString)")
        }
        
        if let statusString = promotionMessageTuple.status {
            if requestString.characters.count > 0 {
                requestString = requestString.stringByAppendingString("&status=\(statusString)")
            }
            else {
                requestString = requestString.stringByAppendingString("status=\(statusString)")
            }
        }
        
        
        let jsonRequestString = requestString .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            print(responseBody!)
            print()
            
        })
        task.resume()
    }
    
    func getPromotionalMessage(completion: (message: String, status: String) -> Void) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_promotional_messages.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [Dictionary<String, String>]
                for dictionary in jsonResponse {
                    completion(message: dictionary["content"]!, status: dictionary["status"]!)
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
        }
        task.resume()
    }
    
    func getCompanySettings(completion: (UIColor) -> Void) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_companySettings.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)\n Data:\(data!)")
                return
            }
            
            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [Dictionary<String, String>]
                for dictionary in jsonResponse {
                    
                    let hexString = dictionary["checkin_image_background_color"]
                    let backgroundColor = UIColor(hexString: hexString!)
                    completion(backgroundColor)
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
        }
        task.resume()

    }
    
}