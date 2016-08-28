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
    var dataController = DataController.sharedInstance
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        //getServiceRecords()
        self.dataController.getServices { (services) in
            dispatch_async(dispatch_get_main_queue(), {
                self.services = services
                self.tableview.reloadData()
            })
        }
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
            self.dataController.updateServiceRecord(service.id, status: service.status)
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
        self.dataController.postServiceRecord(name) { (services) in
            dispatch_async(dispatch_get_main_queue(), {
                self.services = services
                self.tableview.reloadData()
            })
        }
        self.addServiceVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    
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
        self.dataController.updateServiceRecord(service.id, status: service.status)
    }
}