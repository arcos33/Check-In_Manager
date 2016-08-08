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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStylistRecords()
        
    }
    var stylists = Array<AnyObject>()
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int)->Int{
        return self.stylists.count
    }
    
    
    func numberOfSectionsInTableView(tableView:UITableView!)->Int{
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("stylistCell", forIndexPath: indexPath) as! StyleListCell
        let stylist = self.stylists[indexPath.row] as! Dictionary<String, String>
        cell.name.text = stylist["name"]
        if (stylist["status"] == "available") {
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
    
    func didEnterStylistName(name: String) {
        postStylistRecord(name)
        getStylistRecords()
        self.addStylistPopOverVC.dismissViewControllerAnimated(true, completion: nil)
        //url
        //session
        //request
        // perform post request
        // reload data
        // request string
        
    }
    
    func postStylistRecord(name: String) {
        // DEVELOP
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/develop/mobile_api/Create/create_Stylist.php")!
        
        // LIVE
        //let url:NSURL = NSURL(string: "http://www.whitecoatlabs.co/checkin/glamour/mobile_api/post_checkinEvent.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequestString = "name=\(name)&status=available" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print(error)
                return
            }
            
//            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
//            print(responseBody)
            dispatch_async(dispatch_get_main_queue(), {
                //update tableview with name
            })
        })
        task.resume()
    }
    
    func getStylistRecords() {
        // DEVELOP
        let url: NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/develop/mobile_api/Get/get_stylists.php")!
        
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
                        self.populateDataSource(jsonResponseString)
                    }
                    catch {
                        print("error = \(error)")
                    }
                }
            }
            else {
                print("error = \(error)")
            }
            
        }
        task.resume()
    }
    
    func populateDataSource(array: [Dictionary<String, String>]) {
        for item in array {
            self.stylists.append(item)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableview.reloadData()
        }
    }
    
    @IBAction func switchChanged(sender: AnyObject) {
        let switchSelected = sender as! UISwitch
        let cellSelected = switchSelected.superview?.superview as! UITableViewCell
        let indexPath = self.tableview.indexPathForCell(cellSelected)
        let stylist = self.stylists[(indexPath?.row)!] as! Dictionary<String, String>
        var status: String!
        if (switchSelected.on) {
            status = "available"
        }
        else {
            status = "unavailable"
        }
        updateStylistRecord(stylist["id"]!, status: status)
        
    }
    
    func updateStylistRecord(id: String, status: String) {
        // DEVELOP
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/develop/mobile_api/Update/update_Stylist.php")!
        
        // LIVE
        //let url:NSURL = NSURL(string: "http://www.whitecoatlabs.co/checkin/glamour/mobile_api/post_checkinEvent.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequestString = "id=\(id)&status=\(status)" .dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
            guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                print(error)
                return
            }
            
//            let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
//            print(responseBody)
        })
        task.resume()
    }
}
