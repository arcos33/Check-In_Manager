//
//  ServicesOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol ServicesOfferedTableDelegate {
    func didSelectService(service: String)
}

class ServicesOfferedTableViewController: UITableViewController {
    
    var servicesOffered = [Service]()
    var didSetProvider:Bool!
    var providerSelected:String!
    var delegate: ServicesOfferedTableDelegate?
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Try to get a cell
        let service = self.servicesOffered[indexPath.row] as Service
        let cell = UITableViewCell()
        cell.textLabel?.text = service.name
        cell.textLabel?.textAlignment = .Center
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servicesOffered.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetProvider = true
        let service = self.servicesOffered[indexPath.row]
        self.providerSelected = service.name
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectService(service.name)
    }
}
