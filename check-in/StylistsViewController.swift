//
//  StylistsViewController.swift
//  check-in
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit
import CoreData


class StylistsViewController: UIViewController, AddStylistVCDelegate {
    
    @IBOutlet var tableview: UITableView!
    
    var addStylistPopOverVC: AddStylistViewController!
    var stylists = Array<Stylist>()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let cellIdentifier = "stylistCell"

    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        getStylistRecords()
    }
    
    //------------------------------------------------------------------------------
    // MARK: Tableview Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleted = UITableViewRowAction(style: .Destructive, title: "Eliminar") { action, index in
            let stylist = self.stylists[indexPath.row]
            stylist.status = "deleted"
            self.updateStylistRecord(stylist.id, status: stylist.status)
            self.stylists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        deleted.backgroundColor = UIColor.redColor()
        
        return [deleted]
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int)->Int{
        return self.stylists.count
    }
    
    
    func numberOfSectionsInTableView(tableView:UITableView!)->Int{
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StyleListCell
        let stylist = self.stylists[indexPath.row]
        cell.name.text = stylist.name
        if (stylist.status == "available") {
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
        titleLabel.text = "Estilistas"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        vw.addSubview(titleLabel)
        vw.backgroundColor = UIColor.lightGrayColor()
        return vw
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.addStylistPopOverVC = segue.destinationViewController as! AddStylistViewController
        self.addStylistPopOverVC.delegate = self
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    private func postStylistRecord(name: String) {
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
            dispatch_async(dispatch_get_main_queue(), {
                self.getStylistRecords()
            })
        })
        task.resume()
    }
    
    private func getStylistRecords() {
        let url: NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.companyPath)/mobile_api/get/get_stylists.php")!
        
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
                        self.stylists = []
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
            let stylist = Stylist(status: item["status"]!, id: item["id"]!, name: item["name"]!)
            self.stylists.append(stylist)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableview.reloadData()
        }
    }
    
    private func updateStylistRecord(id: String, status: String) {
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
            
            //            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
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
        let stylist = self.stylists[(indexPath?.row)!]
        var status: String!
        if (switchSelected.on) {
            status = "available"
        }
        else {
            status = "unavailable"
        }
        stylist.status = status
        updateStylistRecord(stylist.id!, status: status)
    }
    
    //------------------------------------------------------------------------------
    // MARK: AddStylistVCDelegate Delegate Methods
    //------------------------------------------------------------------------------\
    func didEnterStylistName(name: String) {
        postStylistRecord(name)
        self.addStylistPopOverVC.dismissViewControllerAnimated(true, completion: nil)
    }
}

