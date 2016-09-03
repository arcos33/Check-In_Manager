//
//  StylistsOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol StylistsOfferedTableDelegate {
    func didSelectStylist(stylist: String)
}

class StylistsOfferedTableViewController: UITableViewController {
    
    var stylistsOffered = [Stylist]()
    var didSetStylist:Bool!
    var stylistSelected:String!
    var delegate: StylistsOfferedTableDelegate?
    let dataController = DataController.sharedInstance
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
            }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Try to get a cell
        let stylist = self.stylistsOffered[indexPath.row] as Stylist
        let cell = UITableViewCell()
        cell.textLabel?.text = stylist.name!
        cell.textLabel?.textAlignment = .Center
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stylistsOffered.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetStylist = true
        let stylist = self.stylistsOffered[indexPath.row]
        self.stylistSelected = stylist.name!
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectStylist(stylist.name!)
    }
}
