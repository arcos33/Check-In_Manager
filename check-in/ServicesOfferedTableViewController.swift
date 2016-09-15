//
//  ServicesOfferedTableViewController.swift
//  check-in
//
//  Created by Joel on 8/15/16.
//  Copyright © 2016 JediMaster. All rights reserved.
//

import UIKit

protocol ServicesOfferedTableDelegate {
    func didSelectService(_ service: String)
}

class ServicesOfferedTableViewController: UITableViewController {
    
    var servicesOffered = [Service]()
    var didSetProvider:Bool!
    var providerSelected:String!
    var delegate: ServicesOfferedTableDelegate?
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
        let service = self.servicesOffered[(indexPath as NSIndexPath).row] as Service
        let cell = UITableViewCell()
        cell.textLabel?.text = service.name
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servicesOffered.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSetProvider = true
        let service = self.servicesOffered[(indexPath as NSIndexPath).row]
        self.providerSelected = service.name
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didSelectService(service.name)
    }
}
