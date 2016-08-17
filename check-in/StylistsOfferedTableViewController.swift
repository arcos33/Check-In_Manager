//
//  StylistsOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol StylistTableDelegate {
    func didSelectStylist(stylist: String)
}

class StylistsOfferedTableViewController: UITableViewController {
    
    var stylists: [Stylist]!
    var didSetStylist:Bool!
    var stylistSelected:String!
    var delegate: StylistTableDelegate?
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTableFromNotification) , name: "CheckinVCDidReceiveStylistsNotification", object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc func updateTableFromNotification(notification: NSNotification) {
        self.stylists = notification.object! as! [Stylist]
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Try to get a cell
        let stylist = self.stylists[indexPath.row] as Stylist
        let cell = UITableViewCell()
        cell.textLabel?.text = stylist.name!
        cell.textLabel?.textAlignment = .Center
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stylists.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetStylist = true
        let stylist = self.stylists[indexPath.row]
        self.stylistSelected = stylist.name!
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectStylist(stylist.name!)
    }
}
