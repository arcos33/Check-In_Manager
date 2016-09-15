//
//  PaymentTypesOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/27/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol PaymentTypesOfferedTableDelegate {
    func didSelectPayment(_ payment: String)
}

class PaymentTypesOfferedTableViewController: UITableViewController {
    
    var paymentTypesOffered = [Payment]()
    var didSetProvider:Bool!
    var providerSelected:String!
    var delegate: PaymentTypesOfferedTableDelegate?
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataController = DataController.sharedInstance
    
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //------------------------------------------------------------------------------
    // MARK: TableView Methods
    //------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Try to get a cell
        let payment = self.paymentTypesOffered[(indexPath as NSIndexPath).row] as Payment
        let cell = UITableViewCell()
        cell.textLabel?.text = payment.name
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentTypesOffered.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSetProvider = true
        let payment = self.paymentTypesOffered[(indexPath as NSIndexPath).row]
        self.providerSelected = payment.name
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelectPayment(payment.name)
    }
}
