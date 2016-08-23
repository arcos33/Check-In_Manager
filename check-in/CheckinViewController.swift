//
//  CheckinViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

//
//  CheckInViewController.swift
//  CheckIn-Store
//
//  Created by Joel on 7/27/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit
import CoreData

class CheckInViewController: UIViewController, StylistTableDelegate, ServicesOfferedTableDelegate {
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var stylistButton: UIButton!
    @IBOutlet var servicesButton: UIButton!
    @IBOutlet var companyImageView: UIImageView!
    
    var stylistTable:StylistsOfferedTableViewController?
    var servicesTable:ServicesOfferedTableViewController?
    var checkinEvent: CheckInEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    var stylists = [Stylist]()
    var stylistMapping = Dictionary<String, AnyObject>()
    var services = [Service]()
    var serviceMapping = Dictionary<String, AnyObject>()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = self.appDelegate.companyImage {
            self.companyImageView.image = image
        }
        else {
            self.companyImageView.image = UIImage(named: "placeholder")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
        if segue.identifier == "stylistListSegue" {
            getStylists()
            self.stylistTable = segue.destinationViewController as? StylistsOfferedTableViewController
            self.stylistTable?.delegate = self
            self.stylistTable?.stylists = self.stylists
        }
        else {
            getServices()
            self.servicesTable = segue.destinationViewController as? ServicesOfferedTableViewController
            self.servicesTable?.delegate = self
            self.servicesTable?.services = self.services
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.currentDevice().orientation == .Portrait {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func getStylists() {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_stylists.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                if responseBody != "null" {
                    for object in jsonResponse as! [Dictionary<String, String>] {
                        let stylist = Stylist(status: object["status"]!, id: object["id"]!, name: object["name"]!)
                        if (self.stylistMapping[object["id"]!] == nil) {
                            let objectID = object["id"]!
                            self.stylistMapping[objectID] = stylist
                        }
                        else { // update it
                            stylist.status = object["status"]
                            self.stylistMapping[object["id"]!] = stylist
                        }
                    }
                    var origIdArray = Array<String>()
                    for stylist in self.stylists {
                        origIdArray.append(stylist.id)
                    }
                    
                    self.stylists = []
                    for (_, value) in self.stylistMapping {
                        let stylist = value as! Stylist
                        if stylist.status == "available" {
                            self.stylists.append(stylist)
                        }
                    }
                    var newIdArray = Array<String>()
                    for stylist in self.stylists {
                        newIdArray.append(stylist.id)
                    }
                    
                    if origIdArray != newIdArray {
                        NSNotificationCenter.defaultCenter().postNotificationName("CheckinVCDidReceiveStylistsNotification", object: self.stylists)
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
    
    @objc private func getServices() {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_services.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                if responseBody != "null" {
                    let jsonResponseString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    for object in jsonResponseString as! [Dictionary<String, String>] {
                        let service = Service(name: object["name"]!, id: object["id"]!, status: object["status"]!)
                        if (self.serviceMapping[object["id"]!] == nil) {
                            self.serviceMapping[object["id"]!] = service
                        }
                        else { // update it
                            service.status = object["status"]
                            self.serviceMapping[object["id"]!] = service
                        }
                    }
                    var origIdArray = Array<String>()
                    for service in self.services {
                        origIdArray.append(service.id)
                    }
                    
                    self.services = []
                    for (_, value) in self.serviceMapping {
                        let service = value as! Service
                        if service.status == "available" {
                            self.services.append(service)
                        }
                    }
                    var newIdArray = Array<String>()
                    for service in self.services {
                        newIdArray.append(service.id)
                    }
                    
                    if origIdArray != newIdArray {
                        NSNotificationCenter.defaultCenter().postNotificationName("CheckinVCDidReceiveServicesNotification", object: self.services)
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
    
    private func resetUI() {
        self.nameTextField.text = nil
        self.phoneTextField.text = nil
        self.stylistButton.setTitle("elija Estilista", forState: .Normal)
        self.stylistButton.setTitleColor(UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.00), forState: .Normal)
        self.servicesButton.setTitleColor(UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.00), forState: .Normal)
        self.servicesButton.setTitle("elija Servicio", forState: .Normal)
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    private func formIsComplete() -> Bool {
        if self.nameTextField.text?.characters.count == 0 {
            presentAlert("Ingrese nombre")
            return false
        }
        else if self.phoneTextField.text?.characters.count != 13 {
            presentAlert("Ingrese numero telefonico valido")
            return false
        }
        else if self.serviceSelected == nil {
            presentAlert("Elija un servicio")
            return false
        }
        else {
            return true
        }
    }
    
    private  func presentAlert(message: String) {
        let alert = UIAlertController(title: "Falta informacion", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func submit(sender: AnyObject) {
        if (formIsComplete()) {
            
            let tempCleanString1 = self.phoneTextField.text!.stringByReplacingOccurrencesOfString("(", withString: "")
            let tempCleanString2 = tempCleanString1.stringByReplacingOccurrencesOfString(")", withString: "")
            let tempCleanString3 = tempCleanString2.stringByReplacingOccurrencesOfString("-", withString: "")
            
            let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/create/create_checkinEvent.php")!
            
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.cachePolicy = .ReloadIgnoringLocalCacheData
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let tempCheckinTime = dateFormatter.stringFromDate(NSDate())
            let tempCompletedTimestamp = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: 0))
            
            if self.stylistSelected! == "" {
                self.stylistSelected = "sin preferencia"
            }
            let jsonRequestString = "checkinTimestamp=\(tempCheckinTime)&completedTimestamp=\(tempCompletedTimestamp)&name=\(self.nameTextField.text!)&phone=\(tempCleanString3)&status=checkedin&stylist=\(self.stylistSelected!)&service=\(self.serviceSelected!)" .dataUsingEncoding(NSUTF8StringEncoding)
            
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
                        
                        let tempId = object["id"]!
                        let df = NSDateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        self.checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckInEvent", inManagedObjectContext: self.appDelegate.managedObjectContext) as? CheckInEvent
                        self.checkinEvent!.checkinTimestamp = df.dateFromString(object["checkinTimestamp"]! as! String)
                        self.checkinEvent!.completedTimestamp = df.dateFromString(object["completedTimestamp"]! as! String)
                        self.checkinEvent!.uniqueID = NSNumber(int: tempId.intValue)
                        self.checkinEvent!.name = object["name"] as? String
                        self.checkinEvent!.phone = object["phone"] as? String
                        self.checkinEvent!.status = object["status"] as? String
                        self.checkinEvent!.service = object["service"] as? String
                        self.checkinEvent!.stylist = object["stylist"] as? String
                        do {
                            try self.appDelegate.managedObjectContext.save()
                        }
                        catch {
                            print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                        }
                    }
                }
                catch {
                    print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.resetUI()
                })
            })
            task.resume()
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: UITextField Delegate Methods
    //------------------------------------------------------------------------------
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == self.phoneTextField
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let decimalString = components.joinWithSeparator("") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: StylistsTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectStylist(stylist: String) {
        self.stylistButton.setTitle(stylist, forState: .Normal)
        self.stylistButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.stylistSelected = stylist
    }
    
    // MARK: ServicesOfferedTableDelegate methods
    func didSelectService(service: String) {
        self.servicesButton.setTitle(service, forState: .Normal)
        self.servicesButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.serviceSelected = service
    }
}

class Stylist: NSObject {
    var status: String!
    var id: String!
    var name: String!
    
    init(status: String, id: String, name: String) {
        self.status = status
        self.id = id
        self.name = name
    }
}

class Service: NSObject {
    var name: String!
    var id: String!
    var status: String!
    
    init(name: String, id: String, status: String) {
        self.name = name
        self.id = id
        self.status = status
    }
}