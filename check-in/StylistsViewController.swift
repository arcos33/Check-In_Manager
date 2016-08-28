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
    let dataController = DataController.sharedInstance
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        self.dataController.getStylists { (stylists) in
            dispatch_async(dispatch_get_main_queue(), {
                self.stylists = stylists
                self.tableview.reloadData()
            })
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Tableview Methods
    //------------------------------------------------------------------------------
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleted = UITableViewRowAction(style: .Destructive, title: "Eliminar") { action, index in
            let stylist = self.stylists[indexPath.row]
            stylist.status = "deleted"
            self.dataController.updateStylistRecord(stylist.id, status: stylist.status)
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
        self.dataController.updateStylistRecord(stylist.id, status: stylist.status)
    }
    
    //------------------------------------------------------------------------------
    // MARK: AddStylistVCDelegate Delegate Methods
    //------------------------------------------------------------------------------\
    func didEnterStylistName(name: String) {
        self.dataController.postStylistRecord(name) { (stylists) in
            dispatch_async(dispatch_get_main_queue(), {
                self.stylists = stylists
                self.tableview.reloadData()
                self.addStylistPopOverVC.dismissViewControllerAnimated(true, completion: nil)

            })
        }
    }
}

