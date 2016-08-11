//
//  ServicesViewController.swift
//  check-in
//
//  Created by Joel on 8/8/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import Foundation
import UIKit

class ServicesViewController: UIViewController, AddServiceVCDelegate {
    
    @IBOutlet var tableview: UITableView!
    
    var addServiceVC: AddServiceViewController!
    var services = Array<Service>()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let cellIdentifier = "serviceCell"

    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        getServiceRecords()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.addServiceVC = segue.destinationViewController as! AddServiceViewController
        self.addServiceVC.delegate = self
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleted = UITableViewRowAction(style: .Destructive, title: "Eliminar") { action, index in
            let service = self.services[indexPath.row]
            service.status = "deleted"
            self.updateServiceRecord(service.id, status: service.status)
            self.services.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        deleted.backgroundColor = UIColor.redColor()
        
        return [deleted]
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int)->Int{
        return self.services.count
    }
    
    
    func numberOfSectionsInTableView(tableView:UITableView!)->Int{
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ServiceCell
        let service = self.services[indexPath.row]
        cell.name.text = service.name
        if (service.status == "available") {
            cell.availableSwitch.setOn(true, animated: true)
        }
        else {
            cell.availableSwitch.setOn(false, animated: true)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        let titleLabel = UILabel(frame: CGRectMake(16, 6, 200, 16))
        titleLabel.text = "Servicios"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor.lightGrayColor()
        return vw
    }
    
    //------------------------------------------------------------------------------
    // MARK: AddServiceDelegate Methods
    //------------------------------------------------------------------------------
    func didEnterServiceName(name: String) {
        postServiceRecord(name)
        self.addServiceVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    private func postServiceRecord(name: String) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/create/create_service.php")!
        
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
            dispatch_async(dispatch_get_main_queue(), {
                //update tableview with name
                self.getServiceRecords()

            })
        })
        task.resume()
    }
    
    private func getServiceRecords() {
        let url: NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/get/get_services.php")!
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            if error == nil {
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                if responseBody != "null" {
                    do {
                        let jsonResponseString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [Dictionary<String, String>]
                        self.services = []
                        self.populateDataSource(jsonResponseString)
                    }
                    catch {
                        print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                    }
                }
            }
            else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
        }
        task.resume()
    }
    
    private func populateDataSource(array: [Dictionary<String, String>]) {
        for item in array {
            if item["status"] == "deleted" {
                continue
            }
            let service = Service(name: item["name"]!, id: item["id"]!, status: item["status"]!)
            self.services.append(service)        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableview.reloadData()
        }
    }
    
    private func updateServiceRecord(id: String, status: String) {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/update/update_service.php")!
        
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
            
            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            print(responseBody)
            
        })
        task.resume()
    }

    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func switchChanged(sender: AnyObject) {
        let switchSelected = sender as! UISwitch
        let cellSelected = switchSelected.superview?.superview as! UITableViewCell
        let indexPath = self.tableview.indexPathForCell(cellSelected)
        let service = self.services[(indexPath?.row)!]
        var status: String!
        if (switchSelected.on) {
            status = "available"
        }
        else {
            status = "unavailable"
        }
        service.status = status
        updateServiceRecord(service.id!, status: status)
        
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