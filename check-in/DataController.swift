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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DataController: NSObject {
    static let sharedInstance = DataController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.configuration)
    
    //var managedObjectContext: NSManagedObjectContext
    
    override fileprivate init() {} // This prevents others from using the default '()' initializer for this class.
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(appDelegate.companyPath!)/mobile_api/get/get_checkinEvents.php")!
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            let responseBody = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if responseBody == "null" {
                return
            }
            
            do {
                // Do a fetch request to get all checkinEvent records
                var fetch: NSFetchRequest<NSFetchRequestResult>?
                if #available(iOS 10.0, *) {
                    fetch = CheckInEvent.fetchRequest()
                } else {
                    // Fallback on earlier versions
                    fetch = NSFetchRequest(entityName: Constants.checkInEvent)
                }
                var checkinEvents:[CheckInEvent]?
                do {
                    checkinEvents = try appDelegate.managedObjectContext.fetch(fetch!) as? [CheckInEvent]
                }
                catch {
                    print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                }
                
                if checkinEvents?.count == 0 {
                    // If the response body is valid JSON then iterate through all dictionaries and save checkinEvents to coredata.
//                    let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
//                    print("responseBody: \(responseBody)")
                    print()
                    let jsonResponseString: AnyObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Dictionary<String, AnyObject>] as AnyObject
                    for object in jsonResponseString as! [Dictionary<String,AnyObject>] {
                        let tempId = object["id"]!
                        let checkinEvent = NSEntityDescription.insertNewObject(forEntityName: Constants.checkInEvent, into: appDelegate.managedObjectContext) as! CheckInEvent
                        
                        checkinEvent.checkinTimestamp = Date.dateFromString(object["checkinTimestamp"]! as! String)
                        checkinEvent.uniqueID = NSNumber(value: tempId.int32Value as Int32)
                        checkinEvent.name = object["name"] as? String
                        checkinEvent.phone = object["phone"] as? String
                        checkinEvent.status = object["status"] as? String
                        
                        if let completedTimeStampString = object["completedTimestamp"]! as? String {
                            checkinEvent.completedTimestamp = Date.dateFromString(completedTimeStampString)
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
                            checkinEvent.updateDate = Date.dateFromString(updateDateString)
                        }
                        
                        do {
                            try appDelegate.managedObjectContext.save()
                        }
                        catch {
                            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                        }
                    }
                    NotificationCenter.default.post(name: Notification.didReceiveCheckinRecordsNotification, object: nil)
                }
                else {
                    var existingCheckinEventIDS = Array<Int>()
                    var existingCheckinEventMap = Dictionary<Int, CheckInEvent>()
                    
                    for existingCheckinEvent in checkinEvents! {
                        existingCheckinEventIDS.append((existingCheckinEvent.uniqueID?.intValue)!)
                        existingCheckinEventMap[(existingCheckinEvent.uniqueID?.intValue)!] = existingCheckinEvent
                    }
                    let jsonString: AnyObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    for checkinEventDB in jsonString as! [Dictionary<String,AnyObject>] {
                        let tempID = checkinEventDB["id"]! as! String
                        
                        let tempIdInt = Int(tempID)
                        
                        if !existingCheckinEventIDS.contains(tempIdInt!) {
                            
                            let checkinEvent = NSEntityDescription.insertNewObject(forEntityName: Constants.checkInEvent, into: appDelegate.managedObjectContext) as! CheckInEvent
                            checkinEvent.checkinTimestamp = Date.dateFromString(checkinEventDB["checkinTimestamp"]! as! String)
                            checkinEvent.uniqueID = NSNumber(value: tempIdInt!)
                            checkinEvent.name = checkinEventDB["name"] as? String
                            checkinEvent.phone = checkinEventDB["phone"] as? String
                            checkinEvent.status = checkinEventDB["status"] as? String
                            
                            if let completedTimeStampString = checkinEventDB["completedTimestamp"]! as? String {
                                checkinEvent.completedTimestamp = Date.dateFromString(completedTimeStampString)
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
                                checkinEvent.updateDate = Date.dateFromString(updateDateString)
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
                    NotificationCenter.default.post(name: Notification.didReceiveCheckinRecordsNotification, object: nil)
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }) 
        task.resume()
    }
    
    func setURLIdentifierForCompany(_ companyID: String) {
        let url: URL = URL(string: "http://whitecoatlabs.co/checkin/company_mapping.php")!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonRequest = "company_id=\(companyID)".data(using: String.Encoding.utf8)
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequest, completionHandler: { (data, response, error) in
            guard let data: Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            do {
                let responseBody = String(data: data, encoding: String.Encoding.utf8)
                if responseBody == "null" {
                    NotificationCenter.default.post(name: Notification.didReceiveCompanyIDNotification, object: false)
                    return
                }
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [Dictionary<String, String>]
                for dict in jsonResponse {
                    if (UserDefaults.standard.value(forKey: "companyPath") as? String) == nil {
                        UserDefaults.standard.set(dict["baseURL"], forKey: "companyPath")
                    }
                    self.appDelegate.companyPath = dict["baseURL"]!
                    
                    if (UserDefaults.standard.value(forKey: "companyName") as? String) == nil {
                        UserDefaults.standard.set(dict["company_name"], forKey: "companyName")
                    }
                    self.appDelegate.companyName = dict["company_name"]!
                    
                    if (UserDefaults.standard.value(forKey: "industry") as? String) == nil {
                        UserDefaults.standard.set(dict["industry"], forKey: "industry")
                    }
                    
                    self.appDelegate.companyIndustry = dict["industry"]
                    NotificationCenter.default.post(name: Notification.didReceiveCompanyIDNotification, object: true);
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
            //            let responseBody = String(data: data, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
        }) 
        task.resume()
    }
    
    func checkCredentials(_ username: String, password: String) {
        let url = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/get/get_users.php")
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonRequest = "username=\(username)&password=\(password)" .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequest, completionHandler: { (data, response, error) in
            let responseBody = String(data: data!, encoding: String.Encoding.utf8)
            if responseBody == "correct" {
                NotificationCenter.default.post(name: Notification.didReceiveAuthenticationNotification, object: true)
            }
            else {
                NotificationCenter.default.post(name: Notification.didReceiveAuthenticationNotification, object: false)
            }
            //            print("response = \(responseBody)")
            //            print()
        }) 
        task.resume()
    }
    
    func downloadImage(_ completion: @escaping ((Data) -> Void)) {
        let urlString = "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/check-in_image.png"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)

        let dataTask = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            if (error == nil) {
                if let httpResponse = response as? HTTPURLResponse {
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
        }) 
        dataTask.resume()
    }
    
    func updateCheckInEventAtCellIndex(_ checkinEvent: CheckInEvent!, index: NSInteger?) {
    NotificationCenter.default.post(name: Notification.didReceiveCheckinRecordsNotification, object: index)
        
        let url:URL = URL(string: "http://www.whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/update/update_checkinEvent.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        var requestString = String("id=\(checkinEvent.uniqueID!)")
        let date = Date.stringFromDate(Date.getCurrentLocalDate())
        requestString = requestString! + "&updateDate=\(date)"
        
        if (checkinEvent.completedTimestamp != nil) {
            requestString = requestString! + String("&completedTimestamp=\(checkinEvent.completedTimestamp!)")
        }
        if (checkinEvent.status != nil) {
            requestString = requestString! + String("&status=\(checkinEvent.status!)")
        }
        if (checkinEvent.stylist != nil) {
            requestString = requestString! + String("&stylist=\(checkinEvent.stylist!)")
        }
        if (checkinEvent.service != nil) {
            requestString = requestString! + String("&service=\(checkinEvent.service!)")
        }
        if (checkinEvent.paymentType != nil) {
            requestString = requestString! + String("&paymentType=\(checkinEvent.paymentType!)")
        }
        if (checkinEvent.ticketNumber != nil || checkinEvent.ticketNumber?.characters.count > 0) {
            requestString = requestString! + String("&ticketNumber=\(checkinEvent.ticketNumber!)")
        }
        
        if (checkinEvent.amountCharged != nil || checkinEvent.amountCharged?.characters.count > 0) {
            requestString = requestString! + String("&amountCharged=\(checkinEvent.amountCharged!)")
        }
        
        
        let jsonRequestString = requestString? .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if responseString == "Successfully updated CheckinEvent record" {
                
            }
        })
        task.resume()
    }
    
    func getStylists(_ completion: @escaping (([Stylist]) -> Void)) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/get/get_stylists.php")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                let responseBody = String(data: data!, encoding: String.Encoding.utf8)
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
        }) 
        task.resume()
    }
    
    func getServices(_ completion: @escaping (([Service]) -> Void)) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/get/get_services.php")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let responseBody = String(data: data!, encoding: String.Encoding.utf8)
                var services = [Service]()
                var serviceMapping = Dictionary<String, AnyObject>()
                
                if responseBody != "null" {
                    let jsonResponseString = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
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
                            services.append(service)
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
        }) 
        task.resume()
    }
    
    func getPayments(_ completion: @escaping (([Payment]) -> Void)) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/get/get_payments.php")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let responseBody = String(data: data!, encoding: String.Encoding.utf8)
                var payments = [Payment]()
                var paymentMapping = Dictionary<String, AnyObject>()
                
                if responseBody != "null" {
                    let jsonResponseString = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
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
        }) 
        task.resume()
    }
    
    func updateStylistRecord(_ id: String, status: String) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/update/update_stylist.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonRequestString = "id=\(id)&status=\(status)" .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            NotificationCenter.default.post(name: Notification.stylistRecordsChangedNotification, object: nil)

            //            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
        })
        task.resume()
    }
    
    func updateServiceRecord(_ id: String, status: String) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/update/update_service.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonRequestString = "id=\(id)&status=\(status)" .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            NotificationCenter.default.post(name: Notification.serviceRecordsChangedNotification, object: nil)

            let responseBody = String(data: data!, encoding: String.Encoding.utf8)
            print(responseBody)
        })
        task.resume()
    }
    
    
    func postServiceRecord(_ name: String, completion: @escaping (([Service]) -> Void)) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/create/create_service.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonRequestString = "name=\(name)&status=available" .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            let responseBody = String(data: data!, encoding: String.Encoding.utf8)
            print(responseBody)
            
            NotificationCenter.default.post(name: Notification.serviceRecordsChangedNotification, object: nil)
            self.getServices({ (services) in
                completion(services)
            })
        })
        task.resume()
    }
    
    func postStylistRecord(_ name: String, completion: @escaping (([Stylist]) -> Void)) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/create/create_stylist.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonRequestString = "name=\(name)&status=available" .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            //            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
            NotificationCenter.default.post(name: Notification.stylistRecordsChangedNotification, object: nil)

            self.getStylists({ (stylists) in
                completion(stylists)
            })
        })
        task.resume()
    }
    
    func postCheckinEvent(_ phone: String, name: String, completion: @escaping () -> Void ) {
        
        let tempCleanString1 = phone.replacingOccurrences(of: "(", with: "")
        let tempCleanString2 = tempCleanString1.replacingOccurrences(of: ")", with: "")
        let tempCleanString3 = tempCleanString2.replacingOccurrences(of: "-", with: "")
        
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/create/create_checkinEvent.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        
        let tempCheckinTime = Date.stringFromDate(Date.getCurrentLocalDate())
        let tempCompletedTimestamp = Date.stringFromDate(Date(timeIntervalSince1970: 0))
        
        let locale = Locale.current
        print(NSDate().description(with: locale))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let checkInTimeStamp = formatter.string(from: Date())
        
        let jsonRequestString = "checkinTimestamp=\(checkInTimeStamp)&completedTimestamp=\(tempCompletedTimestamp)&name=\(name)&phone=\(tempCleanString3)&status=checkedin" .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            //                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //                print(responseBody)
            //                print()
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Dictionary<String, AnyObject>]
                for object in jsonResponse {
                    DispatchQueue.main.async(execute: {
                        let tempId = object["id"]!
                        
                        let checkinEvent = NSEntityDescription.insertNewObject(forEntityName: Constants.checkInEvent, into: self.appDelegate.managedObjectContext) as? CheckInEvent
                        let aDate = Date.dateFromString(object["checkinTimestamp"]! as! String)
                        checkinEvent!.checkinTimestamp = aDate
                        checkinEvent!.uniqueID = NSNumber(value: tempId.int32Value as Int32)
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
    
    func updatePromotionMessage(_ promotionMessageTuple: (message: String?, status: String?)) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/update/update_promotional_message.php")!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        var requestString = String()
        
        if let messageString = promotionMessageTuple.message {
            requestString = requestString + "content=\(messageString)"
        }
        
        if let statusString = promotionMessageTuple.status {
            if requestString.characters.count > 0 {
                requestString = requestString + "&status=\(statusString)"
            }
            else {
                requestString = requestString + "status=\(statusString)"
            }
        }
        
        
        let jsonRequestString = requestString .data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            let responseBody = String(data: data!, encoding: String.Encoding.utf8)
            print(responseBody!)
            print()
            
        })
        task.resume()
    }
    
    func getPromotionalMessage(_ completion: @escaping (_ message: String, _ status: String) -> Void) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/get/get_promotional_messages.php")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Dictionary<String, String>]
                for dictionary in jsonResponse {
                    completion(dictionary["content"]!, dictionary["status"]!)
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
        }) 
        task.resume()
    }
    
    func getCompanySettings(_ completion: @escaping (UIColor) -> Void) {
        let url:URL = URL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath!)/mobile_api/get/get_companySettings.php")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response , error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)\n Data:\(data!)")
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Dictionary<String, String>]
                for dictionary in jsonResponse {
                    
                    let hexString = dictionary["checkin_image_background_color"]
                    let backgroundColor = UIColor(hexString: hexString!)
                    completion(backgroundColor)
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
        }) 
        task.resume()

    }
    
}
