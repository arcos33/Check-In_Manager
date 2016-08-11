//
//  ActiveClientsViewController.swift
//  check-in
//
//  Created by JediMaster on 6/26/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ActiveClientsViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var name: UILabel!
    @IBOutlet var checkInTime: UILabel!
    @IBOutlet var type: UILabel!
    
    var checkInEvents: Array<CheckInEvent>?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let cellIdentifier = "activeCheckInCell"
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        fetchCheckedinClients()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(reloadData), userInfo: nil, repeats: true)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func reloadData() {
        // TODO: Make sure this only gets called once
        DataController.sharedInstance.getCheckinRecords()
        fetchCheckedinClients()
        self.tableview.reloadData()
    }
    
    private func saveChanges() {
        do {
            try self.appDelegate.managedObjectContext.save()
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
    }
    
    private func fetchCheckedinClients () {
        let fetch = NSFetchRequest(entityName: "CheckInEvent")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "status == 'checkedin'")
        let sd = NSSortDescriptor(key: "checkinTimestamp", ascending: true, selector: nil)
        fetch.sortDescriptors = [sd]
        do {
            self.checkInEvents = try self.appDelegate.managedObjectContext.executeFetchRequest(fetch) as? Array<CheckInEvent>
        }
        catch {
            print("error: \(#file) \(#line) \(error)")
        }
    }
    
    private func updateCheckInEvent(checkinEvent: CheckInEvent!) {
        let url:NSURL = NSURL(string: "http://www.whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/update_checkinEvent.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(checkinEvent.completedTimestamp!)
        
        let jsonRequestString = "id=\(checkinEvent.uniqueID!)&completedTimestamp=\(dateString)&status=\(checkinEvent.status!)" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            //            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //            print("Response = \(responseString!)")
        })
        task.resume()
    }
    
    private func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.renderInContext(pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.writeToFile(documentsFileName, atomically: true)
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checkInEvents != nil ? self.checkInEvents!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let checkinEvent = self.checkInEvents![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ActiveClientsCell
        cell.name.text = checkinEvent.name
        
        let secondsDifference = checkinEvent.checkinTimestamp?.timeIntervalSinceNow
        let minsDif = abs(secondsDifference! / 60)
        let minsDifInt = Int(minsDif)
        cell.type.text = "\(minsDifInt) mins"
        let df = NSDateFormatter()
        df.dateFormat = "hh:mm a"
        cell.appointmentTime.text = df.stringFromDate(checkinEvent.checkinTimestamp!)
        
        cell.serviceLabel.text = checkinEvent.service
        cell.stylistLabel.text = checkinEvent.stylist
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRectMake(16, 6, 750, 16))
        titleLabel.text = "Nombre                  Servicio                  Estilista                                             Espera"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        //vw.backgroundColor = UIColor(red: 0.70, green: 0.89, blue: 1.00, alpha: 1.00)
        vw.backgroundColor = UIColor(red: 0.00, green: 0.50, blue: 0.00, alpha: 1.00)
        return vw
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let complete = UITableViewRowAction(style: .Destructive, title: "Completado") { action, index in
            let checkedinEvent = self.checkInEvents![indexPath.row]
            checkedinEvent.status = "completed"
            checkedinEvent.completedTimestamp = NSDate()
            self.saveChanges()
            self.updateCheckInEvent(checkedinEvent)
            NSNotificationCenter.defaultCenter().postNotificationName("reloadTable", object: nil)
            self.checkInEvents?.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        complete.backgroundColor = UIColor.redColor()
        
        return [complete]
    }
}