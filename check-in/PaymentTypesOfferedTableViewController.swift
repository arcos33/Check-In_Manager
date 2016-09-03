//
//  PaymentTypesOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/27/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol PaymentTypesOfferedTableDelegate {
    func didSelectPayment(payment: String)
}

class PaymentTypesOfferedTableViewController: UITableViewController {
    
    var paymentTypesOffered = [Payment]()
    var didSetProvider:Bool!
    var providerSelected:String!
    var delegate: PaymentTypesOfferedTableDelegate?
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
        let payment = self.paymentTypesOffered[indexPath.row] as Payment
        let cell = UITableViewCell()
        cell.textLabel?.text = payment.name
        cell.textLabel?.textAlignment = .Center
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentTypesOffered.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetProvider = true
        let payment = self.paymentTypesOffered[indexPath.row]
        self.providerSelected = payment.name
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectPayment(payment.name)
    }
}
